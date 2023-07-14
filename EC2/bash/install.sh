#!/bin/bash
sudo su
sudo apt update
sudo apt -y upgrade
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo \
  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update

sudo apt-get install -y docker-ce docker-ce-cli containerd.io

sudo usermod -aG docker $USER

sudo apt install docker-compose -y

docker --version

mkdir /var/lib/zabbix/ && cd /var/lib/zabbix/ && ln -s /usr/share/zoneinfo/Europe/Kiev localtime && echo 'Europe/Kiev' > timezone && sudo docker network create zabbix-net

sudo docker run --restart=always -d \
--name zabbix-postgres \
--network zabbix-net \
-v /var/lib/zabbix/timezone:/etc/timezone \
-v /var/lib/zabbix/localtime:/etc/localtime \
-e POSTGRES_PASSWORD=zabbix \
-e POSTGRES_USER=zabbix \
-d chikibevchik/zabbix:postgres


sudo docker run --restart=always \
--name zabbix-server \
--network zabbix-net \
-v /var/lib/zabbix/alertscripts:/usr/lib/zabbix/alertscripts \
-v /var/lib/zabbix/timezone:/etc/timezone \
-v /var/lib/zabbix/localtime:/etc/localtime \
-p 10051:10051 -e DB_SERVER_HOST="zabbix-postgres" \
-e POSTGRES_USER="zabbix" \
-e POSTGRES_PASSWORD="zabbix" \
-d chikibevchik/zabbix:server


sudo docker run --restart=always \
--name zabbix-web \
-p 80:8080 -p 443:8443 \
--network zabbix-net \
-e DB_SERVER_HOST="zabbix-postgres" \
-v /var/lib/zabbix/timezone:/etc/timezone \
-v /var/lib/zabbix/localtime:/etc/localtime \
-e POSTGRES_USER="zabbix" \
-e POSTGRES_PASSWORD="zabbix" \
-e ZBX_SERVER_HOST="zabbix-server" \
-e PHP_TZ="Europe/Kiev" \
-d chikibevchik/zabbix:web
