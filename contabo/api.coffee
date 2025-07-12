#!/usr/bin/env coffee

> ../conf/contabo/API.js:@ > ROOT_PASSWORD

{access_token} = await (await fetch(
  'https://auth.contabo.com/auth/realms/contabo/protocol/openid-connect/token'
  {
    method: 'POST'
    headers: { 'content-type': 'application/x-www-form-urlencoded' },
    body: new URLSearchParams({
      ...API
      grant_type: 'password'
    })
  }
)).json()

Authorization = 'Bearer '+access_token

{
  GET
  PUT
  POST
  DELETE
} = new Proxy(
  {}
  get: (_, method) =>
    (url, data, opt)=>
      url = 'https://api.contabo.com/v1/'+url
      opt = opt or {}
      headers = opt.headers = opt.headers or {}
      headers['content-type'] = 'application/json'
      headers['x-request-id'] = crypto.randomUUID()
      headers.Authorization = Authorization
      opt.method = method
      if data
        if method != 'GET'
          opt.body = JSON.stringify(data)
        else
          url += '?'+new URLSearchParams(data).toString()
      console.log url
      r = await fetch(url, opt)
      {status} = r
      if status == 204
        return ''
      if [200,201].includes status
        return await r.json()
      console.error r.status, await r.text()
      throw r
)

export GET=GET
export POST=POST
export PUT=PUT
export DELETE=DELETE

export passwordId = =>
  for i from (await GET('secrets')).data
    console.log 'DELETE secrets', i.name
    await DELETE 'secrets/'+i.secretId

  {
    data
  } = await POST('secrets', {
    name: "initPassword"
    value: ROOT_PASSWORD
    type: "password"
  })

  [{secretId}] = data
  secretId

export vpsIdByIpPrefix = (ip_prefix)=>
  li = []

  instances = await GET('compute/instances')

  for i in instances.data
    ipv4 = i.ipConfig.v4.ip
    if ipv4.startsWith(ip_prefix)
      {instanceId} = i
      console.log [
        ipv4
        i.dataCenter
        i.productName
      ].join('\t')
      li.push [ipv4, instanceId]
  return li

