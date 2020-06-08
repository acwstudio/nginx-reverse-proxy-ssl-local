#!/bin/bash

set -o allexport
source .env.ssl
set +o allexport

dir=$DIR
domains=$DOMAINS

if ! [ "$(ldconfig -p | grep libnss3)" ]; then
    echo "installing libnss3-tools..."
    apt-get update
    apt install wget -y libnss3-tools
fi

echo "libnss3-tools is already in use..."

if ! [ -d "$dir" ]; then
    echo "installing mkcert..."
    export VER="v1.4.1"
    wget -O mkcert https://github.com/FiloSottile/mkcert/releases/download/${VER}/mkcert-${VER}-linux-amd64
    chmod +x mkcert
    mv mkcert /usr/local/bin
    mkcert -install
fi

echo "mkcert is already in use..."

mkcert -key-file $(pwd)/etc/ssl/private/mkcert-key.pem -cert-file $(pwd)/etc/ssl/private/mkcert.pem $domains

docker-compose up --force-recreate -d reverse