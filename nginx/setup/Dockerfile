ARG UBUNTU=23.10
FROM ubuntu:$UBUNTU as build

WORKDIR /app

RUN apt-get update -y 

ADD _ubuntu.sh .

RUN ./_ubuntu.sh

ENV NGINX_USER root
ADD nginx.service nginx.service
ADD bin bin
ADD setup.sh .

ADD ./nginx /etc/nginx
RUN ./setup.sh
RUN rm -rf /tmp && mkdir -p /tmp
ADD cpso.sh .
RUN ./cpso.sh

FROM ubuntu:$UBUNTU

COPY --from=build /usr/local/nginx /usr/local/nginx
COPY --from=build /usr/sbin/nginx /usr/sbin/nginx
COPY --from=build /usr/sbin/_nginx /usr/sbin/_nginx
COPY --from=build /usr/local/src/LuaJIT/lib /usr/local/src/LuaJIT/lib
COPY --from=build /usr/local/lib/lua/ /usr/local/lib/lua/
RUN rm -rf /etc/nginx
COPY --from=build /etc/nginx /etc/nginx

RUN mkdir -p /var/log/nginx &&\
grep -qF -- "root " /etc/security/limits.conf || echo -e "\nwww-data soft nofile 252144\nwww-data hard nofile 262144\n" >>/etc/security/limits.conf 

COPY --from=build /so/ /lib/
ENV LD_LIBRARY_PATH=/lib
CMD ["/usr/sbin/nginx","-g","daemon off;"]
