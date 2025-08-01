ARG UBUNTU=24
FROM ubuntu:$UBUNTU as build

WORKDIR /app

RUN apt-get update -y

ADD _ubuntu.sh .

RUN ./_ubuntu.sh

ENV NGINX_USER root
ADD openresty.service openresty.service
ADD bin bin
ADD setup.sh .

ADD ./openresty /etc/openresty
RUN ./setup.sh
RUN rm -rf /tmp && mkdir -p /tmp
ADD cpso.sh .
RUN ./cpso.sh

FROM ubuntu:$UBUNTU

COPY --from=build /usr/local/openresty /usr/local/openresty
COPY --from=build /usr/sbin/openresty /usr/sbin/openresty
COPY --from=build /usr/local/src/LuaJIT/lib /usr/local/src/LuaJIT/lib
RUN rm -rf /etc/openresty
COPY --from=build /etc/openresty /etc/openresty

RUN mkdir -p /var/log/openresty &&\
  grep -qF -- "root " /etc/security/limits.conf || echo -e "\nwww-data soft nofile 252144\nwww-data hard nofile 262144\n" >>/etc/security/limits.conf

COPY --from=build /so/ /lib/
ENV LD_LIBRARY_PATH=/lib
CMD ["/usr/sbin/openresty","-g","daemon off;"]
