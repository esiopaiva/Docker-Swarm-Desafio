#!/bin/bash
 sudo docker swarm init --advertise-addr 169.254.234.100
 sudo docker swarm join-token worker | grep docker > /vagrant/worker.sh 

sudo apt install nfs-server -y
docker volume create app_data
sudo /bin/sh -c 'echo "/var/lib/docker/volumes/app/_data/ *(rw,sync,subtree_check)" > /adm/exports'
exportfs -ar

mkdir compose
cd compose
wget https://raw.githubusercontent.com/esiopaiva/Docker-Swarm-Desafio/main/docker-compose.yml
docker-compose up -d

docker service create --name app-php --replicas 2 -dt -p 80:80 --mount type=volume,src=app_data,dst=/app/ webdevops/php-apache:alpine-php7
