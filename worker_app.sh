#!/bin/bash
 
 sudo apt install nfs-common -y
 mount 169.254.234.100:/var/lib/docker/volumes/app_data/_data/  /var/lib/docker/volumes/app_data/_data/ 