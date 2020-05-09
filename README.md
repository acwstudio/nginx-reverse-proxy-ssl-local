# nginx-reverse-proxy project
Multiple local domains on localhost through nginx reverse proxy, SSL certificates (mkcert) and Docker
## Introduction
Set up an easy and secure reverse proxy with Docker, Nginx & local ssl sertificate.
You can have on localhost:
1. Multiple services (apps, sites) by local domains
2. SSL certificates 
3. Docker container Nginx
## Host computer requirements
You should have:
- OS Linux (when using other systems, there may be nuances, but I'm not sure)
- Docker version 17.12.0+, and Compose version 1.21.0+.
- mkcert (valid https certificates for localhost)
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

## How is it working
Look at these folders and files. I didn't want to deal with the long name **nginx-revers-proxy** and renamed it 
just **reverse**

![revers](https://github.com/acwstudio/nginx-reverse-proxy/blob/master/nginx-reverse-proxy.png?raw=true)

Our **docker-compose.yml** file defines and runs the nginx reverse proxy. Let's look at the 
**docker-compose.yml**. I use Nginx image from DockerHub to create a docker container. The nginx reverse proxy
listen tipical ports:"80" and "443". Config files forward from host to container by volumes. SSL certificates 
forward from host to container by volumes too.

Let's look at config files. A whole config file was broken down into parts. It was made to select reused 
blocks, to put them in separate files and then just to include them where it needed. Here a list of these 
files:

- common.conf
- common_location.conf
- ssl.conf

The general config file is a **etc/nginx/nginx.conf**. The most important string is 
```nginx
include /etc/nginx/conf.d/sites-enabled/*.conf;
```
The string includes config files from **sites-enabled** folder. Let's go to the folder. The folder consists
symlinks to the config files from **sites-availabel** folder. These files consist blocks to forward request 
to my services (apps, sites). Each service (app, site) has own config file and I named them like their local 
domain names. For example, I have the laravel-docker.local, so config file, I named **laravel-docker.conf**.
The file has strings to include files with repeated blocks:
```nginx
include       /etc/nginx/conf.d/common.conf;
include       /etc/nginx/conf.d/ssl.conf;
-------
include     /etc/nginx/conf.d/common_location.conf;
``` 
