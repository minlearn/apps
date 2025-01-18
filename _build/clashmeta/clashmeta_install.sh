###############

echo "Installing Dependencies"

silent() { "$@" >/dev/null 2>&1; }

silent apt-get install -y curl sudo mc
echo "Installed Dependencies"

mkdir -p /app/clashmeta
wget --no-check-certificate https://github.com/minlearn/appp/raw/master/_build/clashmeta/clashmeta.tar.gz -O /tmp/tmp.tar.gz
tar -xzvf /tmp/tmp.tar.gz -C /app/clashmeta clashmeta --strip-components=1
rm -rf /tmp/tmp.tar.gz

cat > /app/clashmeta/config.yaml << 'EOL'
mode: rule
mixed-port: 7890
allow-lan: true
log-level: error
ipv6: true
secret: ''
external-controller: 127.0.0.1:9090
dns:
  enable: true
  enhanced-mode: fake-ip
  fake-ip-range: 198.18.0.1/16
  nameserver:
  - 114.114.114.114
  - 223.5.5.5
  - 8.8.8.8
  fallback: []
tun:
  enable: false
  stack: gvisor
  dns-hijack:
  - any:53
  auto-route: true
  auto-detect-interface: true
EOL

cat > /lib/systemd/system/clashmeta.service << 'EOL'
[Unit]
Description=this is clashmeta service,please init it with the init.sh
After=network.target nss-lookup.target
Wants=network.target nss-lookup.target
Requires=network.target nss-lookup.target

[Service]
Type=simple
ExecStartPre=/usr/bin/sleep 2
ExecStart=/app/clashmeta/clash-meta -d /app/clashmeta -f /app/clashmeta/config.yaml
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOL

cat > /root/init.sh << 'EOL'
test -f /root/inited || {
  read -p "give a sub download url with proxies:" file
  wget -qO- --no-check-certificate $file|sed -n "/^proxies/,/^$/p" >> /app/clashmeta/config.yaml
  grep -q 'proxies' /app/clashmeta/config.yaml && /app/clashmeta/clash-meta -d /app/clashmeta -t /app/clashmeta/config.yaml && touch /root/inited
  systemctl restart clashmeta
}
EOL
chmod +x /root/init.sh

cat > /root/tun.sh << 'EOL'
read -p "this will open the tun in config,are you sure?(y or n)" -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]
  then
    [[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1
  else
    sed -i ':a;N;$!ba;s/tun:\n\ \ enable: false/tun:\n\ \ enable: true/g' /app/clashmeta/config.yaml
    systemctl restart clashmeta
fi
EOL
chmod +x /root/init.sh

systemctl enable -q --now clashmeta


echo "Cleaning up"
silent apt-get -y autoremove
silent apt-get -y autoclean
echo "Cleaned"

##############
