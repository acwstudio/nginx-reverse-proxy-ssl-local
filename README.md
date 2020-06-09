# nginx-reverse-proxy project
Multiple local domains on localhost through nginx reverse proxy, SSL certificates (mkcert) with Docker
## Introduction
Set up an easy and secure reverse proxy with Docker, Nginx & local ssl sertificate.
You can have on localhost:
1. Multiple services (apps, sites) by local domains
2. SSL certificates for localhost
3. Docker container Nginx revers proxy
## Host computer requirements
You should have:
- OS Linux (when using other systems, there may be nuances, but I'm not sure)
- Docker version 19.03.0+, and Compose version 1.25.0+.
- mkcert (valid https certificates for localhost)
- your own services (apps, sites) behind reverse proxy
- **etc/hosts** file has to have "127.0.0.1  your.local.domain" records

see
[link to description!](https://acwstudio.github.io/nginx-reverse-proxy.html)
 