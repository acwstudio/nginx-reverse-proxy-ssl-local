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
- your own services behind reverse proxy
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

> **reverse-net** network is external. You have to use it in your nginx services are behind the proxy.

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

```nginx
# config file to redirect request (myapp_1.conf)

# name upstream block as you like, I named example
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


## What is a reverse proxy
Let's start with the concept of a reverse proxy. A reverse proxy server is a server that sits in front 
of multiple web servers of apps, sites and services and forwards client requests to those web servers. Let say
we have three sites and each site has local domain name 
- site-1.local 
- site-2.local 
- site_3.local

For example, you send from your browser a request of **site_1.local** and reverse proxy forwards the request to 
the appropriate web server, then return answer to your browser. Next time you send a request of 
**site_2.local** and reverse proxy forwards the request to different appropriate web server. Reverse proxy can 
provide a HTTPS protocol and localhost SSL certificates


- ssl.conf

The general config file is a **etc/nginx/nginx.conf**. The most important string here is 
```nginx
include /etc/nginx/conf.d/sites-enabled/*.conf;
```
The string includes config files from **sites-enabled** folder. Let's go to the folder. The folder consists
symlinks to the config files from **sites-availabel** folder. These files consist of blocks to forward request 
to my services (apps, sites). Each service (app, site) has own config file and I named them like their local 
domain names. For example, I have the laravel-docker.local, so config file, I named **laravel-docker.conf**.
The file has strings to include files with repeated blocks:
```nginx
include       /etc/nginx/conf.d/common.conf;
include       /etc/nginx/conf.d/ssl.conf;
-------
include       /etc/nginx/conf.d/common_location.conf;
``` 
So all files are included step by step into a **nginx.conf** general file. Now we must provide SSL certificates.
I use **mkcert** tool to generate SSL certificats. Here is tutorial to install **mkcert** 
https://kifarunix.com/how-to-create-self-signed-ssl-certificate-with-mkcert-on-ubuntu-18-04/
Go to **etc/ssl/private/** and run in terminal
```bash
mkcert localhost asp.local laravel-docker.local
```
The **mkcert** has generated two files **localhost+2-key.pem** and **localhost+2.pem**. The files are SSL 
certificates for **localhost** (+2 domains **asp.local**, **laravel-docker.local**).

Now our revers proxy is working with HTTPS protocol. But if you use HTTP, then begin to work **redirect.conf** 
file. The file redirects HTTP to HTTPS.