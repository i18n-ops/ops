#!/usr/bin/env coffee

> @3-/hwdns > DEFAULT_VIEW create zoneIdByName showRecordSetByZone rm
  ../conf/dns/CNAME
  ../conf/dns/HOST

zoneId = await zoneIdByName HOST

{recordsets:li} = await showRecordSetByZone {
  zoneId
  type: 'CNAME'
}

to_rm = []

for i from li
  if i.line == DEFAULT_VIEW
    records = i.records.map(
      (i)=>i.slice(0,-1)
    )

    records.sort()
    name = i.name.slice(0,-HOST.length-2)

    now = CNAME[name]
    if now
      if ( now == records[0] and records.length == 1 )
        delete CNAME[name]
      else
        to_rm.push i.id
    else
      to_rm.push i.id

console.log 'to_rm',to_rm

await rm zoneId, to_rm

for [prefix, to] from Object.entries CNAME
  await create(
    zoneId
    'CNAME'
    prefix+'.'+HOST
    [
      [
        DEFAULT_VIEW
        [to]
      ]
    ]
  )
