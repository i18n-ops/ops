#!/usr/bin/env coffee

> @3-/hwdns > DEFAULT_VIEW create zoneIdByName showRecordSetByZone rm
  ../conf/dns/PTR > MAIL
  ../conf/dns/HOST

zoneId = await zoneIdByName HOST

mail_host = 'mail.'+HOST
li = await showRecordSetByZone {
  zoneId
  name: mail_host
}

to_rm = []
for i from li.recordsets
  if ['A','AAAA'].includes i.type
    console.log 'rm', i.type, i.name, i.records
    to_rm.push i.id

await rm zoneId, to_rm


PTR = {
  A:[]
  AAAA:[]
}

for [name,ip_li] from Object.entries(MAIL)
  for ip from ip_li
    if ip.includes '.'
      type = 'A'
    else
      type = 'AAAA'
    PTR[type].push ip
    await create(
      zoneId
      type
      name+'-'+mail_host
      [
        [
          DEFAULT_VIEW
          [
            ip
          ]
        ]
      ]
    )


for [type,li] from Object.entries PTR
  console.log type,li
  await create(
    zoneId
    type
    mail_host
    [
      [
        DEFAULT_VIEW
        li
      ]
    ]
  )
