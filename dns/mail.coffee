#!/usr/bin/env coffee

> @3-/cf/mail.js:CF
  @3-/hwdns/mail.js:HW
  ./mail/CONF

DNS = {
  HW
  CF
}

for [dns_li, conf] from CONF
  for [dns, host_li] from Object.entries dns_li
    srv = DNS[dns]
    for host from host_li
      await srv(host, conf)
