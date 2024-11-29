## 编译
./compile.sh
./dist.sh

## 安装
./setup.sh

## 自动设置主从
./init_master_or_slave.sh

## 拓展阅读

[完美替代 MHA，Maxscale 的高可用故障转移功能你大概还不知道](https://www.sohu.com/a/415708089_411876)

[mariadb 搭建主从复制](https://blog.51cto.com/u_13399333/5119603)

[my.cnf 配置参数设置](https://wanghenshui.github.io/MyRocks_zh_doc/%E5%9B%9B%E3%80%81%E6%80%A7%E8%83%BD%E8%B0%83%E4%BC%98/1.my.cnf%E9%85%8D%E7%BD%AE%E5%8F%82%E6%95%B0%E8%AE%BE%E7%BD%AE.html)

## 从空数据库开始创建主从

在从库运行 ./rebuild_slave.sh 主库ip

## 从备份恢复

./load_backup.sh
