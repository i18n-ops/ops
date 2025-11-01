#!/usr/bin/env coffee

> @3-/hwdns > DEFAULT_VIEW create zoneIdByName showRecordSetByZone rm
  @3-/cf:CF
  @3-/cf/setIp.js:cfSetIp
  ../conf/dns/IP.js > IP_MAIL IP_CF_SRV
  ../conf/dns/HOST.js > HOST_CF_SRV HOST_MAIL HOST_CN_SRV HOST_HW_IP HOST_CF_IP
  ../conf/dns/cn.js:IP_CN

rmByHost = (zoneId, name)=>
  li = await showRecordSetByZone {
    zoneId
    name
  }

  to_rm = []
  for i from li.recordsets
    i_name = i.name
    if i_name.endsWith '.'
      i_name = i_name.slice(0,-1)
    if i_name == name
      if ['A','AAAA'].includes i.type
        console.log 'rm', i.type, i.name, i.records
        to_rm.push i.id

  await rm zoneId, to_rm
  return

dnsMail = =>
  zoneId = await zoneIdByName HOST_MAIL

  mail_host = 'mail.'+HOST_MAIL

  await rmByHost zoneId, mail_host

  PTR = {
    A:[]
    AAAA:[]
  }

  for [name,ipv4,ipv6] from IP_MAIL
    host = name+'-'+mail_host
    await rmByHost zoneId, host
    for [type,ip] from [
      [
        'A'
        ipv4
      ]
      [
        'AAAA'
        ipv6
      ]

    ]
      PTR[type].push ip
      await create(
        zoneId
        type
        host
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
  return


cfSrv = =>
  console.log 'HOST_CF_SRV', HOST_CF_SRV
  host_id = (await CF.get('?name='+HOST_CF_SRV))[0].id
  type_ip = {
    A:new Map
    AAAA:new Map
  }

  dns_url = host_id+'/dns_records'

  for type from ['A','AAAA']
    map = type_ip[type]
    o = await CF.get(dns_url+'?type='+type+'&name='+HOST_CF_SRV)
    for {content, id} from o
      map.set content,id

  to_add = []
  for [name,ipv4,ipv6] from IP_CF_SRV
    for [type, ip] from [
      ['A', ipv4]
      ['AAAA', ipv6]
    ]
      if not type_ip[type].delete ip
        to_add.push [
          name,type,ip
        ]

  for [type, m] from Object.entries(type_ip)
    li = []
    type_ip[type] = [...m.values()]

  for [name, type, ip] from to_add
    update = type_ip[type].pop()
    if update
      await CF.PUT(
        dns_url+'/'+update
        {
          comment: name
          proxied: true
          content: ip
          name: HOST_CF_SRV
          type
        }
      )
    else
      await CF.POST(
        dns_url
        {
          comment: name
          proxied: true
          content: ip
          name: HOST_CF_SRV
          type
        }
      )

  for [type,m] from Object.entries type_ip
    for id from m
      await CF.DELETE(
        dns_url+'/'+id
      )
  return

hwHostCn = =>
  pos = HOST_CN_SRV.indexOf('.')
  zoneId = await zoneIdByName HOST_CN_SRV.slice(pos+1)
  await rmByHost(zoneId, HOST_CN_SRV)
  ipv4_li = []
  ipv6_li = []
  for [name,ipv4,ipv6] from IP_CN
    ipv4_li.push ipv4
    ipv6_li.push ipv6
  for [type,li] from [
    [ 'A', ipv4_li ]
    [ 'AAAA', ipv6_li ]
  ]
    await create(
      zoneId
      type
      HOST_CN_SRV
      [
        [
          DEFAULT_VIEW
          li
        ]
      ]
    )
  return

hostIp = =>
  host_ip = new Map
  for [name, ipv4, ipv6] from IP_CN
    host_ip.set name, [ipv4, ipv6]
  for [name, ipv4, ipv6] from IP_CF_SRV
    host_ip.set name, [ipv4, ipv6]

  for [host, prefix_ip] from Object.entries HOST_CF_IP
    setIp = await cfSetIp(host)
    console.log host, prefix_ip
    if prefix_ip.constructor == String
      ipv4_li = []
      ipv6_li = []
      for hostname from prefix_ip.split(' ')
        [ipv4, ipv6] = host_ip.get hostname
        if ipv4
          ipv4_li.push ipv4
        if ipv6
          ipv6_li.push ipv6
        await setIp('', ipv4_li, ipv6_li)
    else
      for [prefix, hostname] from Object.entries prefix_ip
        [ipv4, ipv6] = host_ip.get hostname
        await setIp(prefix, ipv4, ipv6)

  for [host, prefix_ip] from Object.entries HOST_HW_IP
    zoneId = await zoneIdByName host
    for [prefix, hostname] from Object.entries prefix_ip
      phost = prefix+'.'+host
      await rmByHost(zoneId, phost)
      [ipv4, ipv6] = host_ip.get hostname

      for [type, ip] from [
        [
          'A'
          ipv4
        ]
        [
          'AAAA'
          ipv6
        ]
      ]
        await create(
          zoneId
          type
          phost
          [
            [
              DEFAULT_VIEW
              [
                ip
              ]
            ]
          ]
        )

  return

await hostIp()
# await hwHostCn()
# await cfSrv()
# await dnsMail()
