#!/usr/bin/env bash
DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR
set -ex
[ "$UID" -eq 0 ] || exec sudo "$0" "$@"

NGINX_USER=${NGINX_USER:-"www-data"}

if [ -x "$(command -v apt)" ]; then
  apt-get update
  apt-get install -y libbrotli-dev libpcre3-dev libssl-dev zlib1g-dev git build-essential curl
fi

echo "--- 创建用户和组 ---"
groupadd -r $NGINX_USER 2>/dev/null || true
useradd -r -g $NGINX_USER -s /sbin/nologin -M $NGINX_USER 2>/dev/null || true
mkdir -p /var/log/nginx
chown $NGINX_USER:$NGINX_USER /var/log/nginx
BUILD_DIR="/tmp/nginx-build"
INSTALL_PREFIX="/usr/local/nginx"
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
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR" || error_exit "无法进入目录 $BUILD_DIR"
LATEST_NGINX_VERSION=$( curl -s https://api.github.com/repos/nginx/nginx/releases/latest | jq -r '.tag_name'|awk -F- '{print $2}')
if [ -z "$LATEST_NGINX_VERSION" ]; then
  error_exit "无法从 GitHub Releases 获取最新的 Nginx 版本号。"
fi
echo "最新的 Nginx 版本为: $LATEST_NGINX_VERSION"
NGINX_TARBALL="nginx-${LATEST_NGINX_VERSION}.tar.gz"
NGINX_DIR="nginx-${LATEST_NGINX_VERSION}"
wget -c "https://nginx.org/download/$NGINX_TARBALL" || error_exit "下载 Nginx 失败。"
tar -zxvf "$NGINX_TARBALL" || error_exit "解压 Nginx 失败。"
echo "--- 克隆额外的 Nginx 模块 ---"
# git_clone https://github.com/openresty/lua-nginx-module.git
# git_clone https://github.com/openresty/luajit2.git
git_clone https://github.com/chobits/ngx_http_proxy_connect_module.git
git_clone https://github.com/google/ngx_brotli.git
cd "$BUILD_DIR/ngx_brotli" && git submodule update --init
# echo "--- 编译和安装 LuaJIT ---"
# cd "$BUILD_DIR/luajit2" || error_exit "找不到 LuaJIT 源码目录。"
# make -j"$(nproc)"
# make install
# ln -sf /usr/local/lib/libluajit-5.1.so.2 /lib64/libluajit-5.1.so.2
# export LUAJIT_LIB=/usr/local/lib
# export LUAJIT_INC=/usr/local/include/luajit-2.1
cd "$BUILD_DIR/$NGINX_DIR" || error_exit "无法进入目录 $NGINX_DIR"
echo "--- 应用 proxy_connect_rewrite 补丁 ---"
patch -p1 <"$BUILD_DIR/ngx_http_proxy_connect_module/patch/proxy_connect_rewrite_102101.patch" || error_exit "应用补丁失败。"
echo "--- 修改 Nginx 源码以隐藏版本信息 ---"
sed -i 's@"nginx/"@"-/"@g' src/core/nginx.h
sed -i 's@r->headers_out.server == NULL@0@g' src/http/ngx_http_header_filter_module.c
sed -i 's@r->headers_out.server == NULL@0@g' src/http/v2/ngx_http_v2_filter_module.c
sed -i 's@<hr><center>nginx</center>@@g' src/http/ngx_http_special_response.c
echo "--- 配置编译选项 ---"
./configure \
  --with-cc-opt="-g0 -O3 -fstack-protector-strong -Wformat -Werror=format-security -fPIC -march=native -pipe -flto -funsafe-math-optimizations " \
  --with-openssl-opt='enable-tls1_3 enable-ec_nistp_64_gcc_128' \
  --with-ld-opt="-Wl,-Bsymbolic-functions -Wl,-z,relro -Wl,-z,now -fPIC" \
  --user=$NGINX_USER --group=$NGINX_USER \
  --prefix=$INSTALL_PREFIX \
  --sbin-path=/usr/sbin/nginx \
  --conf-path=/etc/nginx/nginx.conf \
  --pid-path=/var/run/nginx.pid \
  --lock-path=/var/run/nginx.lock \
  --error-log-path=/var/log/nginx/error.log \
  --http-log-path=/var/log/nginx/access.log \
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
  --with-http_gunzip_module \
  --with-http_gzip_static_module \
  --with-file-aio \
  --with-http_sub_module \
  --with-stream=dynamic \
  --with-stream_ssl_module \
  --with-mail=dynamic \
  --with-mail_ssl_module \
  --add-module="$BUILD_DIR/ngx_http_proxy_connect_module" \
  --add-module="$BUILD_DIR/ngx_brotli" \
  --with-cc-opt="-O3 -flto -fomit-frame-pointer" \
  --with-ld-opt="-flto -Wl,-s"

# --add-module="$BUILD_DIR/lua-nginx-module" \

make -j"$(nproc)" || error_exit "编译失败。"
rm -rf /usr/sbin/nginx
make install || error_exit "安装失败。"
nginx -V
$DIR/../init.sh
