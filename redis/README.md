# Redis 集群

## 指定主从关系

其中，我们虽然指定了每个主节点都有一个从节点，但哪个是 7000 的从节点，却是随机分配的，直到集群创建完毕，才能确定是 7003、7004 还是 7005。

但是，有时候，当我们只有 3 台物理节点时，就想要指定主从关系，从而保证高可用。

而指定主从关系，就需要手动操作了。

先创建具有三个主节点的集群，没有从节点

使用添加节点的命令添加从节点，这样就可以在添加时指定它们的主节点，建立主从对应关系

使用以下命令创建主节点

```
redis-cli --cluster create 127.0.0.1:7000 127.0.0.1:7001 127.0.0.1:7002 --cluster-replicas 0
```

```
redis-cli --cluster add-node 127.0.0.1:7003 127.0.0.1:7000 --cluster-slave --cluster-master-id ***************
```

其中：

slave 表示要添加从节点

cluster-master-id 要添加到哪一个主节点，id 是*****

127.0.0.1:7003 要添加的从节点

127.0.0.1:7000 原集群中任意节点

这样添加完后得到的就是指定的想要的节点架构

## 动态增删节点
增加主节点

```
redis-cli --cluster add-node 127.0.0.1:7008 127.0.0.1:7000
```

其中：

127.0.0.1:7008 要向集群添加新的节点

127.0.0.1:7000 原集群中任意节点

这里，节点已经加入集群，但：

由于它还没有分配到 hash slots，所以它还没有数据

由于它是还没有 hash slots 的主节点，所以它不会参与到从节点升级到主节点的选举中

此时，执行 resharding 指令来为它分配 hash slots，这会进入交互式命令行，由用户输入相关信息：

```
redis-cli --cluster reshard 127.0.0.1:7000
```

只需要指定一个节点，redis 会自动发现其他节点。

How many slots do you want to move (from 1 to 16384)?

target node id？

from what nodes you want to take those keys？

第一个问题需要需要填写，如 1000.

第二个问题可以通过命令查看：redis-cli -p 7000 cluster nodes | grep myself

第三个问题：all，这样会从每个节点上移动一部分 hash slots 到新节点

然后开始迁移，每迁移一个 key 就会输出一个点。

待所有迁移完成后，执行下面的指令查看集群是否正常：

```
redis-cli --cluster check 127.0.0.1:7000
```

增加从节点

```
redis-cli --cluster add-node 127.0.0.1:7006 127.0.0.1:7000 --cluster-slave
```

该指令与增加主节点语法一致，与添加主节点不同的是，显式指定了是从节点。

这会为该从节点随机分配一个主节点，优先从那些从节点数目最少的主节点中选取。

如果要在添加从节点时就为其指定主节点，需要指定 master-id，执行下面的指令（需要替换为真实的 id）：

```
redis-cli --cluster add-node 127.0.0.1:7006 127.0.0.1:7000 --cluster-slave --cluster-master-id 3c3a0c74aae0b56170ccb03a76b60cfe7dc1912e
```

另一种添加从节点的方式是添加一个空的主节点，然后把该节点指定为某个主节点的从节点：

```
cluster replicate 3c3a0c74aae0b56170ccb03a76b60cfe7dc1912e
```

## 删除节点

注意，只能删除从节点或者空的主节点，指令如下：

```
redis-cli --cluster del-node 127.0.0.1:7000 <node-id>
```

其中：

127.0.0.1:7000 为集群中任意节点

node-id 为要删除的节点的 id

如果想删除有数据的主节点，必须先执行 resharding 把它的数据分配到其他节点后再删除。
