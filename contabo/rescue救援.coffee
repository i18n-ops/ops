#!/usr/bin/env coffee

> ./api > POST vpsIdByIpPrefix passwordId


vps_li = await vpsIdByIpPrefix(
  '85.239.24'
)

rootPassword = await passwordId()

for [ip,id] from vps_li
  console.log ip

  await POST(
    "compute/instances/#{id}/actions/rescue"
    {
      rootPassword
    }
  )
