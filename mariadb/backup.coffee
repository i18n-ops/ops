#!/usr/bin/env coffee

###

请写脚本, 使用CoffeeScript 配合 zx , dayjs 完成需求
脚本代码要简洁优雅，变量名尽量用单个单词
常量全部大写：比如 BAK、S3 等等
需求：

使用 mariabackup 进行 MariaDB 的增量备份
每月1日做一次全量备份,并删除之前的本地备份
其他日期做增量备份
备份文件命名格式类似 2022/11/01
将备份文件复制到 Backblaze 的S3存储
在上传到S3之前,对备份文件进行zstd压缩,压缩级别18
使用rclone复制压缩文件到远程存储
复制完成后删除本地的压缩文件

全量备份完成后:
1. 本地只保留这个月和上个月的备份,其他都删除
2. 删除远程存储中12个月之前的备份
###

BAK = '/path/to/mariabackup'
S3 = 's3://your-bucket'
TODAY = dayjs().format('YYYY/MM/DD')

backup = (type) =>
  # 准备命令参数
  args = []
  args.push '--target-dir', BAK
  args.push '--user', 'mariadb'
  args.push '--password', 'mariadb-password'

  # 全量备份
  if type is 'full'
    args.push '--full'
    args.push '--compress'

  # 增量备份
  else if type is 'incremental'
    args.push '--incremental'
    args.push '--from-lsn', last_lsn

  # 执行备份命令
  zx.run(`${BAK} ${args.join(' ')}`)

  # 记录增量备份的 LSN
  if type is 'incremental'
    last_lsn = zx.output.match(/LSN: (.*)/)[1]

# 脚本入口
last_lsn = ''

# 每月1日进行全量备份
if TODAY.split('/')[1] == '01'
  backup('full')

# 其他日期进行增量备份
else
  backup('incremental')

# 压缩备份文件
compressed = zx.pipe(`zstd -18 ${BAK}/${TODAY}.tar.gz`)

# 上传到 S3
rclone.copy(compressed, `${S3}/${TODAY}.tar.gz`)

# 删除本地压缩文件
zx.rm(compressed)

# 本地保留最近两个月的备份
zx.rm(`${BAK}/*.tar.gz`, { olderThan: '1m' })

# 删除远程存储 12 个月之前的备份
rclone.delete(`${S3}/*.tar.gz`, { olderThan: '12m' })

