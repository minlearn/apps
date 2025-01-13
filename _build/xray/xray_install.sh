###############

silent() { "$@" >/dev/null 2>&1; }

echo "Installing Dependencies"
silent apt-get install -y curl sudo mc
echo "Installed Dependencies"

mkdir -p /app/xray
wget --no-check-certificate https://github.com/minlearn/appp/raw/master/_build/xray/xray.tar.gz -O /tmp/tmp.tar.gz
tar -xzvf /tmp/tmp.tar.gz -C /app/xray xray --strip-components=1
rm -rf /tmp/tmp.tar.gz

cat > /lib/systemd/system/xray.service << 'EOL'
[Unit]
Description=this is xray service,please change the token then daemon-reload it
After=network.target nss-lookup.target
Wants=network.target nss-lookup.target
Requires=network.target nss-lookup.target

[Service]
Type=simple
ExecStartPre=/usr/bin/bash -c "date=$$(echo -n $$(ip addr |grep $$(ip route show |grep -o 'default via [0-9]\\{1,3\\}.[0-9]\\{1,3\\}.[0-9]\\{1,3\\}.[0-9]\\{1,3\\}.*' |head -n1 |sed 's/proto.*\\|onlink.*//g' |awk '{print $$NF}') |grep 'global' |grep 'brd' |head -n1 |grep -o '[0-9]\\{1,3\\}.[0-9]\\{1,3\\}.[0-9]\\{1,3\\}.[0-9]\\{1,3\\}/[0-9]\\{1,2\\}') |cut -d'/' -f1);PATH=/usr/local/bin:$PATH exec sed -i s/xxx.xxxxxx.com/$${date}/g /app/xray/config.json"
ExecStart=/app/xray/xray -c /app/xray/config.json
Restart=on-failure
RestartPreventExitStatus=23

[Install]
WantedBy=multi-user.target
EOL

cat > /app/xray/config.json << 'EOL'
{
  "log": null,
  "routing": {
    "domainStrategy": "AsIs",
    "rules": [
      {
        "inboundTag": [
          "api"
        ],
        "outboundTag": "api",
        "type": "field"
      },
      {
        "type": "field",
        "port": "443",
        "network": "udp",
        "outboundTag": "blocked"
      },
      {
        "type": "field",
        "domain": [
          "www.gstatic.com"
        ],
        "outboundTag": "direct"
      },
      {
        "ip": [
          "geoip:cn"
        ],
        "outboundTag": "blocked",
        "type": "field"
      },
      {
        "outboundTag": "blocked",
        "protocol": [
          "bittorrent"
        ],
        "type": "field"
      },
      {
        "type": "field",
        "outboundTag": "vps-outbound-v4",
        "domain": [
          "api.myip.com"
        ]
      },
      {
        "type": "field",
        "outboundTag": "vps-outbound-v6",
        "domain": [
          "api64.ipify.org"
        ]
      },
      {
        "type": "field",
        "outboundTag": "direct",
        "network": "udp,tcp"
      }
    ]
  },
  "dns": null,
  "inbounds": [
    {
      "listen": "127.0.0.1",
      "port": 62789,
      "protocol": "dokodemo-door",
      "settings": {
        "address": "127.0.0.1"
      },
      "streamSettings": null,
      "tag": "api",
      "sniffing": null
    },
    {
      "listen": null,
      "port": 443,
      "protocol": "vless",
      "settings": {
        "clients": [
          {
            "id": "xxxxxxxxxxxxxxxxx",
            "flow": ""
          }
        ],
        "decryption": "none",
        "fallbacks": []
      },
      "streamSettings": {
        "network": "ws",
        "security": "tls",
        "tlsSettings": {
          "serverName": "localhost",
          "rejectUnknownSni": false,
          "minVersion": "1.2",
          "maxVersion": "1.3",
          "cipherSuites": "",
          "certificates": [
            {
              "ocspStapling": 3600,
              "certificateFile": "/app/xray/certs/localhost.crt",
              "keyFile": "/app/xray/certs/localhost.key"
            }
          ],
          "alpn": [
            "http/1.1",
            "h2"
          ],
          "settings": [
            {
              "allowInsecure": false,
              "fingerprint": "",
              "serverName": ""
            }
          ]
        },
        "wsSettings": {
          "path": "/mywebsocket",
          "headers": {
            "Host": "xxx.xxxxxx.com"
          }
        }
      },
      "tag": "inbound-443",
      "sniffing": {
        "enabled": true,
        "destOverride": [
          "http",
          "tls",
          "quic"
        ]
      }
    }
  ],
  "outbounds": [
    {
      "protocol": "blackhole",
      "tag": "blocked"
    },
    {
      "tag": "direct",
      "protocol": "freedom",
      "settings": {
        "domainStrategy": "UseIPv4v6"
      }
    },
    {
      "tag": "vps-outbound-v4",
      "protocol": "freedom",
      "settings": {
        "domainStrategy": "UseIPv4v6"
      }
    },
    {
      "tag": "vps-outbound-v6",
      "protocol": "freedom",
      "settings": {
        "domainStrategy": "UseIPv6v4"
      }
    }
  ],
  "transport": null,
  "policy": {
    "system": {
      "statsInboundDownlink": true,
      "statsInboundUplink": true
    },
    "levels": {
      "0": {
        "handshake": 10,
        "connIdle": 100,
        "uplinkOnly": 2,
        "downlinkOnly": 3,
        "bufferSize": 10240
      }
    }
  },
  "api": {
    "services": [
      "HandlerService",
      "LoggerService",
      "StatsService"
    ],
    "tag": "api"
  },
  "stats": {},
  "reverse": null,
  "fakeDns": null
}
EOL

cat > /root/token.sh << 'EOL'
read -p "give a uuid:" token
sed -i s#xxxxxxxxxxxxxxxxx#${token}#g /app/xray/config.json
systemctl restart xray
EOL
chmod +x /root/token.sh

cat > /root/ip.sh << 'EOL'
read -p "give a ip:" ip
date=$(echo -n $(ip addr |grep $(ip route show |grep -o 'default via [0-9]\{1,3\}.[0-9]\{1,3\}.[0-9]\{1,3\}.[0-9]\{1,3\}.*' |head -n1 |sed 's/proto.*\|onlink.*//g' |awk '{print $NF}') |grep 'global' |grep 'brd' |head -n1 |grep -o '[0-9]\{1,3\}.[0-9]\{1,3\}.[0-9]\{1,3\}.[0-9]\{1,3\}/[0-9]\{1,2\}') |cut -d'/' -f1)
sed -i s#${date}#${ip}#g /app/xray/config.json
systemctl restart xray
EOL
chmod +x /root/ip.sh

systemctl enable -q --now xray


echo "Cleaning up"
silent apt-get -y autoremove
silent apt-get -y autoclean
echo "Cleaned"

##############
