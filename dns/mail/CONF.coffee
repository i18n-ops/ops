#!/usr/bin/env coffee

# DMARC Record Checker - Verify Your DMARC Records for errors  https://www.progist.net/tools/dmarc

DMARC_MAIL='i18n-dmarc@googlegroups.com'
DMARC = "v=DMARC1;p=none;rua=mailto:#{DMARC_MAIL};pct=100;ruf=mailto:#{DMARC_MAIL};fo=1;aspf=s;adkim=s;"
FORWORD_TO = 'mailtie=i18n.site@gmail.com'
# MX_FORWORD = 'mx.mailtie.com'

export default [
  [
    {
      HW:[
        'i18n.site'
      ]
      CF:[
        'user0.cf'
      ]
    }
    {
      MX: [
        'u2-mail.i18n.site'
        'u1-mail.i18n.site'
        'u3-mail.i18n.site'
      ]
      TXT: [
        'v=spf1 mx include:_spf.google.com a:mail.i18n.site ~all ra=spf'
      ]
      DMARC
    }
  ]
  [
    {
      HW:[
        '3ti.site'
      ]
      CF:[
        'u-01.eu.org'
      ]
    }
  #   {
  #     MX: [
  #       MX_FORWORD
  #     ]
  #     TXT: [
  #       FORWORD_TO
  #       'v=spf1 include:_spf.google.com ~all'
  #     ]
  #     DMARC
  #   }
  # ]
]
