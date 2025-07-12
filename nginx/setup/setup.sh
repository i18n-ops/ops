#!/usr/bin/env bash

set -ex

VER_LUA_NGINX_MODULE=$(curl -s https://api.github.com/repos/openresty/lua-nginx-module/tags | grep -Eo '"name":.*?[^\\]",' | head -n 1 | cut -d\" -f4)

NGINX_USER=${NGINX_USER:-"www-data"}

DIR=$(dirname $(realpath "$0"))
cd $DIR

if [ -x "$(command -v apt)" ]; then
  $DIR/_ubuntu.sh
fi

clean_up() { # Perform pre-exit housekeeping
  return
}

error_exit() {
  echo -e "${PROGNAME}: ${1:-"Unknown Error"}" >&2
  clean_up
  exit 1
}

git_clone() {
  dir=$(basename $1)
  name=$1
  shift
  if [ ! -d "$dir" ]; then
    git clone --depth=1 --recursive https://github.com/$name.git $@ $BUILDDIR/$dir || error_exit "failed git clone $name"
  fi
}

BUILDDIR="/tmp/nginx-build"
rm -rf $BUILDDIR
mkdir -p $BUILDDIR

cd $BUILDDIR

git_clone openresty/lua-nginx-module -b $VER_LUA_NGINX_MODULE

lua_add() {
  git_clone openresty/$1
  cd $1
  make install
  cd ..
}

lua_add lua-resty-core
lua_add lua-resty-lrucache

# ---------------------------------------------------------------------------
# nginxquiccompile.sh - Compile nginx with boringssl.

# By i81b4u.

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License at <http://www.gnu.org/licenses/> for
# more details.

# Usage: nginxquiccompile.sh [-h|--help]

# Revision history:
# 2020-10-01 Initial release.
# ---------------------------------------------------------------------------
PROGNAME=${0##*/}
VERSION="1.0.0"

cd $BUILDDIR

lastVer() {
  git ls-remote --refs --sort="version:refname" --tags $1 | cut -d/ -f3- | tail -n1
}

git_clone openresty/headers-more-nginx-module
git_clone google/ngx_brotli
git_clone openresty/luajit2
#git_clone slact/nchan
git_clone vision5/ngx_devel_kit

export LUAJIT_LIB=/usr/local/src/LuaJIT/lib
export LUAJIT_INC=/usr/local/src/LuaJIT/include/luajit-2.1

if [ ! -d "$LUAJIT_LIB" ]; then
  cd luajit2
  make -j $(nproc) || error_exit "Error compiling luajit2"
  make install PREFIX=/usr/local/src/LuaJIT
  cd ..
fi

graceful_exit() {
  clean_up
  exit
}

signal_exit() { # Handle trapped signals
  case $1 in
  INT)
    error_exit "Program interrupted by user"
    ;;
  TERM)
    echo -e "\n$PROGNAME: Program terminated" >&2
    graceful_exit
    ;;
  *)
    error_exit "$PROGNAME: Terminating on unknown signal"
    ;;
  esac
}

usage() {
  echo -e "Usage: $PROGNAME [-h|--help]"
}

checkdeps_warn() {
  printf >&2 "$PROGNAME: $*\n"
}

checkdeps_iscmd() {
  command -v "$@" >&-
}

checkdeps() {
  local -i not_found
  for cmd; do
    checkdeps_iscmd "$cmd" || {
      checkdeps_warn $"$cmd not found"
      let not_found++
    }
  done
  ((not_found == 0)) || return 1
}

help_message() {
  cat <<-_EOF_
  $PROGNAME ver. $VERSION
  Compile nginx with boringssl.

  $(usage)

  Options:
  -h, --help  Display this help message and exit.

  NOTE: You must be the superuser to run this script.

  Modify variable BUILDDIR in this script to specify different build path.

_EOF_
  return
}

# Trap signals
trap "signal_exit TERM" TERM HUP
trap "signal_exit INT" INT

# Check for root UID
if [[ $(id -u) != 0 ]]; then
  error_exit "You must be the superuser to run this script."
fi

# Parse command-line
while [[ -n $1 ]]; do
  case $1 in
  -h | --help)
    help_message
    graceful_exit
    ;;
  -* | --*)
    usage
    error_exit "Unknown option $1"
    ;;
  *)
    echo "Argument $1 to process..."
    ;;
  esac
  shift
done

# Main logic

# Check dependencies (https://stackoverflow.com/questions/20815433/how-can-i-check-in-a-bash-script-if-some-software-is-installed-or-not)
echo "$PROGNAME: Checking dependencies..."
checkdeps git hg ninja wget patch sed make || error_exit "Install dependencies before using $PROGNAME"

# Create empty build environment
# echo "$PROGNAME: Cleaning up previous build..."
# if [ -d "$BUILDDIR" ]; then
#   if [ -d "$BUILDDIR/nginx" ]; then
#     rm -rf $BUILDDIR/nginx || error_exit "Failed to delete directory $BUILDDIR/nginx"
#   fi
#   if [ -d "$BUILDDIR/boringssl" ]; then
#     rm -rf $BUILDDIR/boringssl || error_exit "Failed to delete directory $BUILDDIR/boringssl"
#   fi
# else
#   mkdir $BUILDDIR || error_exit "Failed to create directory $BUILDDIR."
# fi

# Get nginx and boringssl
echo "$PROGNAME: Cloning repositories..."
if [ ! -d "nginx" ]; then
  wget -c $(curl -s https://api.github.com/repos/nginx/nginx/tags | jq -r ".[0].zipball_url") -O nginx.zip
  unzip nginx.zip
  mv nginx-nginx-* nginx
fi

# git_clone google/boringssl
#
# # Build boringssl
# echo "$PROGNAME: Building boringssl..."
# mkdir -p $BUILDDIR/boringssl/build || error_exit "Failed to create directory $BUILDDIR/boringssl/build."
# cd $BUILDDIR/boringssl/build || error_exit "Failed to make $BUILDDIR/boringssl/build current directory."
# cmake -GNinja .. || error_exit "Failed to cmake boringssl."
#
# cpu_count=$(nproc)
# if [ $cpu_count -eq 1 ]; then
#   cpu_count=1
# else
#   ((cpu_count = cpu_count - 1))
# fi
#
# ninja -j$cpu_count || error_exit "Faied to compile boringssl."
#
# # Modifications to boringssl to satisfy nginx
# echo "$PROGNAME: Modifying boringssl for nginx..."
# mkdir -p $BUILDDIR/boringssl/.openssl/lib || error_exit "Failed to create directory $BUILDDIR/boringssl/.openssl/lib."
#
# rm -rf $BUILDDIR/boringssl/.openssl/include
# ln -s $BUILDDIR/boringssl/include/ $BUILDDIR/boringssl/.openssl/include || error_exit "Failed to create symlink $BUILDDIR/boringssl/.openssl/include."
# cp $BUILDDIR/boringssl/build/crypto/libcrypto.a $BUILDDIR/boringssl/.openssl/lib || error_exit "Failed to copy file $BUILDDIR/boringssl/build/crypto/libcrypto.a."
# cp $BUILDDIR/boringssl/build/ssl/libssl.a $BUILDDIR/boringssl/.openssl/lib || error_exit "Failed to copy file $BUILDDIR/boringssl/build/ssl/libssl.a."

groupadd $NGINX_USER || true
useradd $NGINX_USER -g $NGINX_USER -s /sbin/nologin -M || true
mkdir -p /var/log/nginx
chown $NGINX_USER:$NGINX_USER /var/log/nginx

git_clone chobits/ngx_http_proxy_connect_module
# git_clone itoffshore/nginx-upstream-fair
# Configure-options like ubuntu
echo "$PROGNAME: Configure build options..."
if [ -d "$BUILDDIR/nginx" ]; then
  cd $BUILDDIR/nginx || error_exit "Failed to make $BUILDDIR/nginx current directory."
  patch -p1 <$BUILDDIR/ngx_http_proxy_connect_module/patch/proxy_connect_rewrite_102101.patch
  ./auto/configure \
    --user=$NGINX_USER --group=$NGINX_USER \
    --prefix=/usr/local/nginx \
    --sbin-path=/usr/sbin/nginx \
    --conf-path=/etc/nginx/nginx.conf \
    --pid-path=/var/run/nginx.pid \
    --lock-path=/var/run/nginx.lock \
    --error-log-path=/var/log/nginx/error.log \
    --http-log-path=/var/log/nginx/access.log \
    --with-cc-opt="-g0 -O3 -fstack-protector-strong -Wformat -Werror=format-security -fPIC -Wdate-time -march=native -pipe -flto -funsafe-math-optimizations --param=ssp-buffer-size=4 -D_FORTIFY_SOURCE=2 " --with-ld-opt="-Wl,-Bsymbolic-functions -Wl,-z,relro -Wl,-z,now -fPIC " \
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
    --with-http_xslt_module=dynamic \
    --with-stream=dynamic --with-stream_ssl_module \
    --with-mail=dynamic \
    --with-mail_ssl_module \
    --with-openssl-opt='enable-tls1_3 enable-ec_nistp_64_gcc_128' \
    --add-module=$BUILDDIR/lua-nginx-module \
    --add-module=$BUILDDIR/headers-more-nginx-module \
    --add-module=$BUILDDIR/ngx_devel_kit \
    --add-module=$BUILDDIR/ngx_brotli \
    --add-module=$BUILDDIR/ngx_http_proxy_connect_module
  # --add-module=$BUILDDIR/nchan \
  # --with-openssl=$BUILDDIR/boringssl \
  # -L$BUILDDIR/boringssl/.openssl/lib/
  # -I$BUILDDIR/boringssl/.openssl/include/
  # --add-module=$BUILDDIR/nginx-upstream-fair \
else
  error_exit "Directory $BUILDDIR/nginx does not exist."
fi

# Modify nginx http server string (nginx -> i81b4u)
echo "$PROGNAME: Modify nginx http server string..."
cd $BUILDDIR/nginx

sed -i 's@"nginx/"@"-/"@g' src/core/nginx.h

# sd -s "if (r->headers_out.server == NULL)" "if (0)" $(rg -l "headers_out.server == NULL")
sed -i 's@<hr><center>nginx</center>@@g' src/http/ngx_http_special_response.c

cd ..

# Make and install
echo "$PROGNAME: Make and install nginx..."
if [ -d "$BUILDDIR/nginx" ]; then
  # touch $BUILDDIR/boringssl/.openssl/include/openssl/ssl.h || error_exit "Failed to touch $BUILDDIR/boringssl/.openssl/include/openssl/ssl.h."
  cd $BUILDDIR/nginx || error_exit "Failed to make $BUILDDIR/nginx current directory."
  make -j $(nproc) || error_exit "Error compiling nginx."

  if [ -d "/etc/nginx" ]; then
    rm -rf /etc/nginx.bak
    mv /etc/nginx /etc/nginx.bak
  fi

  make install || error_exit "Error installing nginx."

  if [ -d "/etc/nginx.bak" ]; then
    rm -rf /etc/nginx
    mv /etc/nginx.bak /etc/nginx
  fi
else
  error_exit "Directory $BUILDDIR/nginx does not exist."
fi

grep -qF -- "$NGINX_USER " /etc/security/limits.conf || echo -e "\n$NGINX_USER soft nofile 252144\n$NGINX_USER hard nofile 262144\n" >>/etc/security/limits.conf
grep -qF -- "^root " /etc/security/limits.conf || echo -e "\nroot soft nofile 655350\nroot hard nofile 655350\n" >>/etc/security/limits.conf
grep -qF -- "pam_limits.so" /etc/pam.d/common-session || echo -e "\nsession required pam_limits.so\n" >>/etc/pam.d/common-session

if [ -f "/etc/sudoers" ]; then
  grep -qF -- "$NGINX_USER " /etc/sudoers || echo -e "\n$NGINX_USER ALL=(root) NOPASSWD: /usr/sbin/service nginx *\n" >>/etc/sudoers
fi

rm /etc/ld.so.cache
ldconfig

mv /usr/sbin/nginx /usr/sbin/_nginx
cp $DIR/bin/nginx /usr/sbin

if [ ! -d "/etc/nginx/site/.keep" ]; then
  if [ -d "$DIR/nginx" ]; then
    rm -rf /etc/nginx
    cp -R $DIR/nginx /etc/nginx
  fi
fi

CPU_NUM=$(nproc)
CPU_HALF=$((CPU_NUM / 2))
[ $CPU_HALF -lt 1 ] && CPU_HALF=1
sed -i "s/worker_processes *[0-9]*;/worker_processes $CPU_HALF;/" /etc/nginx/nginx.conf

cp $DIR/nginx.service /lib/systemd/system/
if [ ! -d "/sys/fs/cgroup/docker" ]; then
  if [ -x "$(command -v systemctl)" ]; then
    systemctl daemon-reload
    systemctl enable nginx --now
    systemctl status nginx --no-pager
  fi
fi

echo "$PROGNAME: All done!"
graceful_exit
