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
## Let's start
Clone the project
```bash
$ mkdir ~/projects
$ cd ~/projects/
$ git clone git@github.com:acwstudio/nginx-reverse-proxy.git
$ cd ~/projects/nginx-reverse-proxy/
```
Right now you have the structure. Look at this!

![revers0](https://github.com/acwstudio/nginx-reverse-proxy/blob/master/nginx-reverse-proxy_0.png?raw=true)

- **docker-compose.yml** file defines and runs multi-container Docker applications.

```yaml
version: '3.7'

services:
  reverse:
    container_name: reverse
    hostname: reverse
    restart: always
    image: nginx:alpine
    ports:
      - 80:80
      - 443:443
    volumes:
      - ./etc/nginx/conf.d/:/etc/nginx/conf.d
      - ./etc/nginx/nginx.conf:/etc/nginx/nginx.conf
      - ./etc/ssl/private/:/etc/ssl/private
    networks:
      reverse-net:

networks:
  reverse-net:
    # the network provides connection to your services behind the proxy
    external: true
```

> **reverse-net** network is external. You have to use it in your nginx services behind the proxy.

- **etc/nginx/nginx.conf** file is a root config one. 

It different from the default file by only one string

```nginx
# default file
include /etc/nginx/conf.d/*.conf;
# project file
include /etc/nginx/conf.d/sites-enabled/*.conf;
```
The string includes symlinks from a **sites-enabled** folder

- **etc/nginx/conf.d/sites-enabled/** is place to put symlinks to config files from **sites-available** folder

- **etc/nginx/conf.d/sites-available/** folder contains config files for redirecting the request to the appropriate
application behind the proxy. You nave to create them. They have strings to include files:

    * **etc/nginx/conf.d/common.conf**, 
    * **etc/nginx/conf.d/common_location.conf**, 
    * **etc/nginx/conf.d/ssl.conf**

These files contain repeated blocks. You just each time include them, look at below
```nginx
# config file to redirect request (myapp_1.conf)

# name upstream block as you like, I named myapp_1
upstream myapp_1 {
  # server is a nginx container name of your myapp_1
  server        myapp_1_nginx;
}

server {
  listen        443 ssl;
  # server_name is a localhost domain from /etc/hosts file
  server_name   myapp_1.local;
  include       /etc/nginx/conf.d/common.conf;
  include       /etc/nginx/conf.d/ssl.conf;

  location / {
    # proxy pass is "http://" + upstream block (look at first string of the file)
    proxy_pass  http://myapp_1;
    include     /etc/nginx/conf.d/common_location.conf;
  }
}
```
- **etc/nginx/conf.d/redirect.conf** is config block listens the 80 port and redirects all request to the 443 port 
https protocol.

- **etc/ssl/private/** is place to put SSL certificates. To create certificates, you need to use
[mkcert](http://brain.nohau.ru/doku.php?id=create-locally-trusted-ssl-certificates). Before generation the local 
certificates, go to **etc/ssl/private/** to put them just in right place.
```bash
$ cd ~/projects/nginx-reverse-proxy/etc/ssl/private
# include all of needed local domains (/etc/hosts)
$ mkcert localhost myapp_1.local myapp_2 127.0.0.1 :: 1
```
Then edit two strings **etc/nginx/conf.d/ssl.conf** file
```nginx
#...........
ssl_certificate        /etc/ssl/private/name_your_certificate.pem;
ssl_certificate_key    /etc/ssl/private/name_your_certificate-key.pem;
#...........
```

Type in your browser http://myapp_1.local.