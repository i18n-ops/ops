可以指定运行的服务器
```
./run.sh optional/nginx.yml -l g0
```

如果有服务器想手动部署

```
rsync -avz ubuntu 主机名:~/
apt-get update && apt-get install -y ansible
ansible-playbook -i localhost, -c local ubuntu/04_apt.yml
```
