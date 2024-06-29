#!/usr/bin/env coffee

> @3-/cf
  @3-/cf/Zone
  fs > existsSync
  path > join
  @3-/write
  @3-/read

ROOT = import.meta.dirname

INITED_JSON = join ROOT, 'inited.json'

if existsSync INITED_JSON
  INITED = JSON.parse read INITED_JSON
else
  INITED = []

ON = 'on'
OFF = 'off'
CONF = {
  ct:
    alerting: enabled: false
  settings:
    automatic_https_rewrites: ON
    browser_check:OFF
    cache_level: 'simplified'
    challenge_ttl: 31536000
    min_tls_version: '1.2'
    '0rtt': ON
    fonts: ON
    http3: ON
    origin_max_http_version: '2'
    security_level:'essentially_off'
    # strict 会导致 backblaze HTTP/2 526 , 估计是因为没有类似nginx的proxy_ssl_name导致的
    # ssl: 'strict'
    ssl: 'full'
    tls_1_3: ON
  argo:
    tiered_caching: ON
}

main = =>
  # https://developers.cloudflare.com/api
  for i from await cf.GET()
    {name, id, status} = i
    inited = INITED.includes name
    if inited
      status = 'inited'
    console.log '❯ '+name,status
    if inited
      continue
    if status != 'active'
      continue
    zone = Zone id

    for [k,v] from Object.entries(CONF)
      t = zone[k]
      for [k1,v1] from Object.entries v
        await t[k1] v1
    INITED.push name
  return

await main()
write INITED_JSON,JSON.stringify INITED
