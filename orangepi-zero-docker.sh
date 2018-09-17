#Après téléchargement de http://www.orangepi.org/downloadresources/orangepizero/2017-05-05/orangepizero_e7c74a532b47c34968b5098.html
sudo apt-get -y update
sudo apt-get -y upgrade
sudo apt-get -y install ca-certificates
sudo wget -qO- https://get.docker.com/ | sh
sudo echo "allow-hotplug wlan0" > /etc/network/interfaces
#see https://hub.docker.com/r/haugene/transmission-openvpn-proxy/
mkdir /home/hhoareau/download
#sudo docker run --cap-add=NET_ADMIN --device=/dev/net/tun -d -v /home/hhoareau/download/:/data  -v /etc/localtime:/etc/localtime:ro -e OPENVPN_PROVIDER=HIDEMYASS -e OPENVPN_CONFIG="CA Toronto" -e OPENVPN_USERNAME=hhoareau@gmail.com  -e WEBPROXY_ENABLED=false -e LOCAL_NETWORK=192.168.1.98/16 --log-driver json-file --log-opt max-size=10m -p 9091:9091 -e OPENVPN_PASSWORD= haugene/transmission-openvpn
sudo docker run --privileged -d -v /home/hhoareau/download/:/data -e "OPENVPN_PROVIDER=HIDEMYASS" -e "OPENVPN_USERNAME=hhoareau" -e "OPENVPN_PASSWORD=" -p 9092:9091 haugene/transmission-openvpn

docker run --name transmission --restart=always -d \
		--add-host=dockerhost:192.168.1. \
		--dns=<ip of dns #1> --dns=<ip of dns #2> \
		-p <transmission webui port>:9091 \
		--cap-add=NET_ADMIN \
		-v <path to torrent dir to scan>:/watchdir \
		-v <path to completed dir>:/downloaddir \
		-v <path to incompleted dir>:/incompletedir \
		-v <path to transmission home dir>:/transmissionhome \
		-v <path to squid3 config dir>:/squidconfig \
		-v <path to squid3 logs dir>:/var/log/squid3 \
		-v /etc/localtime:/etc/localtime:ro \
		-e "INSTALL_TRANSMISSION_WEB_CONTROL=<download and install Transmission Web Control at first start [true/false]>"
		-e "OPENVPN_PROVIDER=HIDEMYASS" \
		-e "OPENVPN_USERNAME=hhoareau" \
		-e "OPENVPN_PASSWORD=" \
		-e "OPENVPN_OPTS=--inactive 3600 --ping 10 --ping-exit 60" \
		-e "LOCAL_NETWORK=192.168.1.98/16" \
		ahuh/arm-transmissionvpn

echo "Creation de la configuration de nginx"
mkdir /home/hhoareau/nginx
echo "events {worker_connections 1024;}" > /home/hhoareau/nginx/nginx.conf
echo "http {server {listen 8080;  location / { proxy_pass http://192.168.1.98:9092; } } }" >> /home/hhoareau/nginx/nginx.conf
more /home/hhoareau/nginx/nginx.conf
sudo docker run -d -v /home/hhoareau/nginx/nginx.conf:/etc/nginx/nginx.conf:ro -p 9091:8080 nginx
