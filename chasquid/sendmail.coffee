#!/usr/bin/env coffee

> nodemailer

{user,to,pass,smtp,subject} = process.env

if not smtp
  smtp = 'smtp.'+user.split('@').pop()

console.log 'smtp ', smtp

transporter = nodemailer.createTransport({
    host: smtp
    debug: true
    logger: true
    secure: true
    port: 465
    auth: {
      user
      pass
    }
})

subject = subject or " 🚀 test mail from #{user} #{new Date().toISOString().slice(0,19).replace('T',' ')} "

mail = {
    from: "WAC.Tax<#{user}>"
    to
    subject
    text: subject
    html: "<h1>#{subject}</h1>"
}

console.log await transporter.sendMail(mail)
console.log subject
