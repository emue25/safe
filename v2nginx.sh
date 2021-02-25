#!\bin\bash

echo -n "Nama Domain : "
read domain

echo -n "Alamat Email : "
read email

echo -n "V2Ray Port : "
read port

# use the new config
read -r -d '' conf <<"EOT"
server {
        listen 82;
        listen [::]:82;

        # SSL configuration
        #
        listen 80 ssl default_server;
        listen [::]:80 ssl default_server;
        ssl on;
        ssl_certificate /etc/letsencrypt/live/v_domain/fullchain.pem;
        ssl_certificate_key /etc/letsencrypt/live/v_domain/privkey.pem;
        ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
        ssl_ciphers HIGH:!aNULL:!MD5;

        #
        # Note: You should disable gzip for SSL traffic.
        # See: https://bugs.debian.org/773332
        #
        # Read up on ssl_ciphers to ensure a secure configuration.
        # See: https://bugs.debian.org/765782
        #
        # Self signed certs generated by the ssl-cert package
        # Don't use them in a production server!
        #
        # include snippets/snakeoil.conf;

        root /var/www/html;

        # Add index.php to the list if you are using PHP
        index index.html index.htm index.nginx-debian.html;

        server_name v_domain;

        location / {
                # First attempt to serve request as file, then
                # as directory, then fall back to displaying a 404.
                try_files $uri $uri/ =404;
        }

        location /ray { # Consistent with the path of V2Ray configuration
            if ($http_upgrade != "websocket") { # Return 404 error when WebSocket upgrading negotiate failed
                return 404;
            }
            proxy_redirect off;
            proxy_pass http://127.0.0.1:v_port; # Assume WebSocket is listening at localhost on port of 10000
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
            proxy_set_header Host $host;
            # Show real IP in v2ray access.log
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        }
}
EOT

# installing
apt install software-properties-common -y
apt install certbot -y

# creating SSL Certificates
certbot certonly --standalone --preferred-challenges http --agree-tos --email $email -d $domain --agree-tos
certbot renew --force-renewal
apt install nginx -y

# update config
cd /etc/nginx/sites-available
mv default ~/default-nginx.conf
echo "$conf" > default

sed -i "s/v_domain/$domain/g" default
sed -i "s/v_port/$port/g" default

systemctl restart nginx
