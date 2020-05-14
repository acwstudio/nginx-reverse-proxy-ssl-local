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
- your own services (instead my asp.local and laravel-docker.local) behind reverse proxy
- **etc/hosts** file has to have "127.0.0.1  your.local.domain" records
## Quick start
```bash
git clone git@github.com:acwstudio/nginx-reverse-proxy.git revers
cd ~/projects/reverse/
docker-compose up -d
```
The **docker-compose.yml** provides connection between reverse service and **asp_nginx_dev**, **MyApp-nginx**
services.
```dockerfile
version: '3'

services:
  reverse:
    container_name: reverse
    ...
    networks:           <--
      - MyApp_net       <-- network name of **MyApp_nginx**
      - dev_asp-network <-- network name of **asp_nginx_dev**
networks:               <--
  MyApp_net:            <--
    external: true      <--
  dev_asp-network:      <--
    external: true      <--
```
Create own config files instead **asp.conf** and **laravel-docker.conf**.

It needed to do for each your service network.
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
listens tipical ports:"80" and "443". Config files forward from host to container by volumes. SSL certificates 
forward from host to container by volumes too.

Let's look at config files. A whole config file was broken down into parts. It was made to select reused 
blocks, to put them in separate files and then just to include them where it needed. Here a list of these 
files:

- common.conf
- common_location.conf
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