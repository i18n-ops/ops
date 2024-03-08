#!/usr/bin/env coffee

> @3-/cf
  @3-/cf/Zone

ON = 'on'
OFF = 'off'
CONF = {
  settings:
    min_tls_version: '1.0'
    browser_check:OFF
    security_level:'essentially_off'
    challenge_ttl: 31536000
    # strict 有时候会导致 HTTP/2 526
    # ssl: 'strict'
    ssl: 'full'
    cache_level: 'simplified'
  argo:
    tiered_caching: ON
}

main = =>
  # https://developers.cloudflare.com/api
  for i from await cf.GET()
    {name, id} = i
    console.log '\n'+name
    zone = Zone id

    ing = []
    for [k,v] from Object.entries(CONF)
      t = zone[k]
      for [k1,v1] from Object.entries v
        ing.push t[k1] v1

    await Promise.all ing


  return

await main()
