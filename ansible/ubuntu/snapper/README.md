# snapper 删除配置

从 /etc/snapper/configs/ 中删除配置文件
从 /etc/default/snapper 中删除配置名称

列出备份
snapper -c root list

查看差异 (1..2 是编号)
snapper -c root status 1..2

也可以查看差异的内容 (用 diff)
