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

console.log data, 'secretId', secretId, typeof secretId

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

instances = await GET('compute/instances')

to_reinstall = []

IP_PREFIX = '85.239.24'

for i in instances.data
  ipv4 = i.ipConfig.v4.ip
  if ipv4.startsWith(IP_PREFIX)
    {instanceId} = i
    console.log 'reinstall', ipv4, i.region
    to_reinstall.push [ipv4, instanceId]

# 危险, 注释掉会真的重装
process.exit 0

await Promise.all to_reinstall.map ([ipv4,instanceId])=>
  console.log ipv4, await PUT(
    'compute/instances/'+instanceId
    {
      imageId
      defaultUser: 'root'
      rootPassword: secretId
    }
  )
  return
