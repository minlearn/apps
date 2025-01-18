###############

silent() { "$@" >/dev/null 2>&1; }

echo "Installing Dependencies"
silent apt-get install -y curl sudo mc
echo "Installed Dependencies"

echo "Installing tm"
mkdir -p /usr/lib/x86_64-linux-musl
wget --no-check-certificate https://github.com/minlearn/appp/raw/master/_build/traffmonetizer/tm.tar.gz -O /tmp/tm.tar.gz
tar -xzvf /tmp/tm.tar.gz -C /usr/lib/x86_64-linux-musl tm/app/usrlibx86_64-linux-musl/{libz.so.1,libstdc++.so.6,libssl.so.1.1,libgcc_s.so.1,libcrypto.so.1.1} --strip-components=3
tar -xzvf /tmp/tm.tar.gz -C /lib tm/app/lib/ld-musl-x86_64.so.1 --strip-components=3
tar -xzvf /tmp/tm.tar.gz -C /etc tm/app/etc/ld-musl-x86_64.path --strip-components=3
tar -xzvf /tmp/tm.tar.gz -C /usr/local/bin tm/app/Cli --strip-components=2
rm -rf /tmp/tm.tar.gz
echo "Installed tm"

cat > /lib/systemd/system/tm.service << 'EOL'
[Unit]
Description=this is Traffmonetizer service,please bash /root/token.sh to change the token
After=network.target nss-lookup.target
Wants=network.target nss-lookup.target
Requires=network.target nss-lookup.target

[Service]
Environment="DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=true"
Environment="DOTNET_CLI_TELEMETRY_OPTOUT=1"
Type=simple
ExecStartPre=/usr/bin/sleep 2
ExecStart=/usr/bin/bash -c "PATH=/usr/local/bin:$PATH exec /usr/local/bin/Cli start accept --token xxxxxxxxxxxxxxxx --device-name amd-$$[RANDOM%%65535]"
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOL

cat > /root/token.sh << 'EOL'
read -p "give a token:" token
sed -i "s#xxxxxxxxxxxxxxxx#${token}#g" /lib/systemd/system/tm.service
systemctl daemon-reload
systemctl restart tm
EOL
chmod +x /root/token.sh

systemctl enable -q --now tm


echo "Cleaning up"
silent apt-get -y autoremove
silent apt-get -y autoclean
echo "Cleaned"

##############
