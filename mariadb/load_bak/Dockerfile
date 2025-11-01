FROM mariadb:11.5.2

# 安装 python3 和 myrocks_hotbackup.py 脚本所需的 python3-mysqldb 库
RUN apt-get update && \
  apt-get install -y python3 python3-mysqldb mariadb-plugin-rocksdb && \
  rm -rf /var/lib/apt/lists/*

# Copy MyRocks configuration
COPY myrocks.cnf /etc/mysql/conf.d/myrocks.cnf

# 复制用户提供的 hotbackup 脚本到镜像中
COPY myrocks_hotbackup.py /usr/local/bin/myrocks_hotbackup

# 授予脚本执行权限
RUN chmod +x /usr/local/bin/myrocks_hotbackup

# 复制用于处理数据库恢复逻辑的自定义入口点脚本。
COPY docker-restore-entrypoint.sh /usr/local/bin/

# 使脚本可执行。
RUN chmod +x /usr/local/bin/docker-restore-entrypoint.sh

ENTRYPOINT ["docker-restore-entrypoint.sh"]

# mariadb 镜像的默认命令是 "mariadbd"。
# 我们的入口点脚本最终会调用原始入口点，然后由它运行此命令。
CMD ["mariadbd"]
