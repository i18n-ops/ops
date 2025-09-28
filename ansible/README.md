新服务器初始化, 先编辑 `../conf/ansible/vps.ini` ， 然后运行

```
./ubuntu.sh
./run.sh optional/zh_CN.yml
```

`./run.sh` 可以运行当个文件，比如

```
./run.sh optional/mariadb.yml
```

服务器如果想运行 ansible 部署到其他服务器, 先运行: `./sh/setup.sh` 安装 `ansible`

可以指定运行的服务器
```
./run.sh optional/nginx.yml -l g0
```

如果有服务器想手动部署某个步骤

```
rsync -avz ubuntu 主机名:~/
apt-get update && apt-get install -y ansible
ansible-playbook -i localhost, -c local ubuntu/04_apt.yml
```