#!/bin/bash
 sudo docker swarm init --advertise-addr 169.254.234.100
 sudo docker swarm join-token worker | grep docker > /vagrant/worker.sh 