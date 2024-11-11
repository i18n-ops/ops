#!/usr/bin/env coffee

> ./api > vpsIdByIpPrefix passwordId GET PUT

{
  data
} = await GET('compute/images', {name:'Ubuntu',orderBy:'lastModifiedDate:desc'})

for i from data
  {name} = i
  # console.log i.name
  if name == 'ubuntu-24.04'
    imageId = i.imageId
    console.log 'imageId', imageId, name
    break

rootPassword = await passwordId()


vps_li = await vpsIdByIpPrefix(
  '85.239.24'
)

console.log vps_li

# 危险, 注释掉会真的重装
process.exit 0

# await Promise.all vps_li.map ([ipv4,instanceId])=>
#   console.log ipv4, await PUT(
#     'compute/instances/'+instanceId
#     {
#       imageId
#       defaultUser: 'root'
#       rootPassword
#     }
#   )
#   return
