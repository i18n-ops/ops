#!/usr/bin/env coffee

> @3-/cf
  @3-/cf/Zone
  path > basename

{argv} = process

[
  backblaze_prefix # f003 , f004 等等, 浏览可以公开访问的仓库的文件，下载链接的域名前缀
  bucket
  tld
  prefix # 域名前缀（可选）
] = argv.slice(2)

if not tld
  console.log "#{basename argv[1]} backblaze_prefix bucket tld [prefix]"
  process.exit(0)

host = if prefix then prefix+'.'+tld else tld

backblazeb2 = backblaze_prefix + '.backblazeb2.com'

console.log '\n'+tld, '→', 'https://'+backblazeb2+'/'+bucket+'/'


bind = (id)=>
  await Promise.allSettled [
    cf.PUT(
      [
        id
        'rulesets/phases/http_response_headers_transform/entrypoint'
      ]
      rules: [
        action: "rewrite"
        action_parameters:
          headers:
            "Access-Control-Allow-Origin":
              operation: "set"
              value: "*"
            "X-Bz-Upload-Timestamp":
              operation: "remove"
            "accept-ranges":
              operation: "remove"
            "age":
              operation: "remove"
            "date":
              operation: "remove"
            "last-modified":
              operation: "remove"
            "nel":
              operation: "remove"
            "report-to":
              operation: "remove"
            "x-bz-content-sha1":
              operation: "remove"
            "x-bz-file-id":
              operation: "remove"
            "x-bz-file-name":
              operation: "remove"
            "x-bz-info-src_last_modified_millis":
              operation: "remove"
            "x-cloud-trace-context":
              operation: "remove"
        description: "rmHead"
        expression: "true"
        enabled: true
      ]
    )
    cf.POST(
      [
        id
        'dns_records'
      ]
      content: backblazeb2
      data: {}
      name: host
      proxiable: true
      proxied: true
      ttl: 1
      type: 'CNAME'
      zone_id: id
      zone_name: tld
      comment: ''
      tags: []
    )
    cf.PUT(
      [
        id
        'rulesets/phases/http_request_transform/entrypoint'
      ]
      {
        rules:[
          action: "rewrite"
          action_parameters:
            uri:
              path:
                expression: 'concat("/file/'+bucket+'", http.request.uri.path)'
          description: host+' → b2:'+bucket
          expression: '(http.host eq '+JSON.stringify(host)+')'
          enabled: true
        ]
      }
    )
  ]

for {id,status} from await cf.GET('?name='+tld)
  console.log 'ID '+id, status
  try
    await bind id
  catch e
    console.log e
