#!/usr/bin/env bash

set -ex

[ "$UID" -eq 0 ] || exec sudo "$0" "$@"

DIR=$(dirname $(realpath "$0"))
cd $DIR

NGINX_USER=${NGINX_USER:-"www-data"}

if [ -x "$(command -v apt)" ]; then
  $DIR/_ubuntu.sh
fi

echo "--- 准备编译环境 ---"
apt-get install -y libpcre3-dev libssl-dev zlib1g-dev libgd-dev libxml2-dev libxslt1-dev git build-essential curl

groupadd $NGINX_USER || true
useradd $NGINX_USER -g $NGINX_USER -s /sbin/nologin -M || true
mkdir -p /var/log/nginx
chown $NGINX_USER:$NGINX_USER /var/log/nginx

BUILD_DIR="/tmp/openresty-build"
INSTALL_PREFIX="/usr/local/openresty"

error_exit() {
  echo "错误: $1" >&2
  exit 1
}

git_clone() {
  local repo_url=$1
  local repo_name
  repo_name=$(basename "$repo_url" .git)
  local target_dir="$BUILD_DIR/$repo_name"

  if [ -d "$target_dir" ]; then
    echo "仓库 '$repo_name' 已存在，跳过克隆。"
  else
    echo "克隆仓库 '$repo_name'..."
    git clone --depth 1 "$repo_url" "$target_dir" || error_exit "克隆 '$repo_url' 失败。"
  fi
}

echo "创建构建目录: $BUILD_DIR"
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR" || error_exit "无法进入目录 $BUILD_DIR"

echo "--- 从 GitHub Releases 获取最新的 OpenResty 版本号 ---"
LATEST_OPENRESTY_VERSION=$(curl -s https://github.com/openresty/openresty/releases |
  grep -oP 'href="/openresty/openresty/releases/tag/v\K[0-9.]+"' |
  head -n 1 |
  sed 's/"//g')

if [ -z "$LATEST_OPENRESTY_VERSION" ]; then
  error_exit "无法从 GitHub Releases 获取最新的 OpenResty 版本号。"
fi
echo "最新的 OpenResty 版本为: $LATEST_OPENRESTY_VERSION"

OPENRESTY_TARBALL="openresty-${LATEST_OPENRESTY_VERSION}.tar.gz"
OPENRESTY_DIR="openresty-${LATEST_OPENRESTY_VERSION}"

wget -c "https://openresty.org/download/$OPENRESTY_TARBALL" || error_exit "下载 OpenResty 失败。"

tar -zxvf "$OPENRESTY_TARBALL" || error_exit "解压 OpenResty 失败。"

cd "$OPENRESTY_DIR" || error_exit "无法进入目录 $OPENRESTY_DIR"

echo "--- 创建用户和目录 ---"
groupadd -r "$NGINX_USER" 2>/dev/null || true
useradd -r -g "$NGINX_USER" -s /sbin/nologin -M "$NGINX_USER" 2>/dev/null || true
mkdir -p /var/log/nginx
chown "$NGINX_USER":"$NGINX_USER" /var/log/nginx

echo "--- 克隆额外的 Nginx 模块 ---"
git_clone https://github.com/chobits/ngx_http_proxy_connect_module.git
git_clone https://github.com/google/ngx_brotli.git
cd "$BUILD_DIR/ngx_brotli" && git submodule update --init

cd $BUILD_DIR/$OPENRESTY_DIR/bundle
NGINX_SOURCE_DIR=$(find . -maxdepth 1 -type d -regextype posix-extended -regex './nginx-[0-9]+.*')
cd "$NGINX_SOURCE_DIR" || error_exit "找不到 Nginx 源码目录。"
echo "进入 Nginx 源码目录: $(pwd)"
echo "应用 proxy_connect_rewrite 补丁..."
patch -p1 <"$BUILD_DIR/ngx_http_proxy_connect_module/patch/proxy_connect_rewrite_102101.patch" || error_exit "应用补丁失败。"

echo "--- 修改 Nginx 源码, 隐藏 Server 头 ---"
sed -i 's@"nginx/"@"-/"@g' src/core/nginx.h
sed -i 's@r->headers_out.server == NULL@0@g' src/http/ngx_http_header_filter_module.c
sed -i 's@r->headers_out.server == NULL@0@g' src/http/v2/ngx_http_v2_filter_module.c
sed -i 's@<hr><center>nginx</center>@@g' src/http/ngx_http_special_response.c

cd ../..

mkdir -p /var/log/openresty
chown $NGINX_USER:$NGINX_USER /var/log/openresty

echo "--- 配置编译选项 ---"
./configure \
  --user=$NGINX_USER --group=$NGINX_USER \
  --prefix=$INSTALL_PREFIX \
  --sbin-path=/usr/sbin/nginx \
  --conf-path=/etc/openresty/nginx.conf \
  --pid-path=/var/run/openresty.pid \
  --lock-path=/var/run/openresty.lock \
  --error-log-path=/var/log/openresty/error.log \
  --http-log-path=/var/log/openresty/access.log \
  --with-cc-opt="-g0 -O3 -fstack-protector-strong -Wformat -Werror=format-security -fPIC -Wdate-time -march=native -pipe -flto -funsafe-math-optimizations --param=ssp-buffer-size=4 -D_FORTIFY_SOURCE=2" \
  --with-ld-opt="-Wl,-Bsymbolic-functions -Wl,-z,relro -Wl,-z,now -fPIC" \
  --with-pcre-jit \
  --with-http_ssl_module \
  --with-http_stub_status_module \
  --with-http_realip_module \
  --with-http_auth_request_module \
  --with-http_v2_module \
  --with-http_v3_module \
  --with-http_dav_module \
  --with-http_slice_module \
  --with-threads \
  --with-http_addition_module \
  --with-ipv6 \
  --with-http_geoip_module=dynamic \
  --with-http_gunzip_module \
  --with-http_gzip_static_module \
  --with-http_image_filter_module=dynamic \
  --with-file-aio \
  --with-http_sub_module \
  --with-stream=dynamic --with-stream_ssl_module \
  --with-mail=dynamic \
  --with-mail_ssl_module \
  --with-openssl-opt='enable-tls1_3 enable-ec_nistp_64_gcc_128' \
  --add-module="$BUILD_DIR/ngx_http_proxy_connect_module" \
  --add-module="$BUILD_DIR/ngx_brotli" \
  -j"$(nproc)"

echo "--- 开始编译 ---"
make -j"$(nproc)" || error_exit "编译失败。"

echo "--- 开始安装 ---"
make install || error_exit "安装失败。"

cp -f $DIR/openresty.service /etc/systemd/system/
rm /usr/sbin/openresty
ln -s /usr/local/openresty/bin/openresty /usr/sbin/
echo "--- OpenResty 安装完成！ ---"
echo "安装路径: $INSTALL_PREFIX"
openresty -V
