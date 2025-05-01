echo "Installing FRP Server... 默认架构: Amd64，其他架构请自行更改脚本"
echo "请确保使用root运行script"
sudo apt-get update
sudo apt-get install -y wget
wget https://gh.llkk.cc/https://github.com/fatedier/frp/releases/download/v0.34.1/frp_0.34.1_linux_amd64.tar.gz --no-check-certificate
tar -zxvf frp_0.34.1_linux_amd64.tar.gz
sudo mkdir /frp
sudo mv frp_0.34.1_linux_amd64/* /frp
echo "安装完成，进行自动配置Server中"
read -p "要设置的链接密码（token）：" -e pwd
read -p "是否需要关闭强制TLS链接？（建议关闭）（仅输入true/false）：" -e yn_tls
read -p "要设置的服务端监听端口（默认7000 TCP）：" -e port
echo 'bindPort = '$port'

auth.method = "token"
auth.token = "'$pwd'"
vhostHTTPPort = 80
vhostHTTPSPort = 443

transport.tls.force = '$yn_tls'' > /frp/frps.toml
sudo chmod +x /frp/frps
echo "配置完成，设置Server服务中"
sudo echo '[Unit]
Description = FRP Server Service
After = network.target syslog.target
Wants = network.target

[Service]
TimeoutStartSec=infinity
ExecStartPre=/bin/sleep 10
Restart=on-failure
RestartSec=5s
Type = simple
ExecStart = /frp/frps -c /frp/frps.toml

[Install]
WantedBy = multi-user.target' > /etc/systemd/system/frps.service
sudo systemctl daemon-reload
sudo systemctl enable frps
sudo systemctl start frps
echo "Server服务启动成功"
echo "连接端口：$port"
echo "连接TOKEN：$pwd"
echo "注意：若转发80/443端口，请使用http/https隧道或者手动修改/frp/frps.toml的vhost有关配置！“
