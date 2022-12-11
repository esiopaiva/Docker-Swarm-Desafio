#!/bin/bash
 sudo docker swarm init --advertise-addr 169.254.234.100
 sudo docker swarm join-token worker | grep docker > /vagrant/worker.sh 


cd /vagrant/
docker-compose up -d

docker volume create app_data

sudo cp /vagrant/index.php /var/lib/docker/volumes/app_data/_data/

#sudo apt install nfs-server -y
#sudo /bin/sh -c 'echo "/var/lib/docker/volumes/app_data/_data/ *(rw,sync,subtree_check)" > /etc/exports'
#exportfs -ar

docker service create --name app-php --replicas 2 -dt -p 80:80 --mount type=volume,src=app_data,dst=/app/ webdevops/php-apache:alpine-php7
