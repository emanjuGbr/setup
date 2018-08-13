# add ssl specific settings
keepalive_timeout    600;
send_timeout 600;
proxy_read_timeout 3500;

# limit ciphers
ssl_ciphers "EECDH+AESGCM:EDH+AESGCM:AES256+EECDH:AES256+EDH";
ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
ssl_prefer_server_ciphers    on;
ssl_session_cache shared:SSL:10m;
add_header Strict-Transport-Security "max-age=63072000; includeSubdomains; preload";
add_header X-Frame-Options SAMEORIGIN;
add_header X-Content-Type-Options nosniff;
# ssl_session_tickets off; # Requires nginx >= 1.5.9
# ssl_stapling on; # Requires nginx >= 1.3.7
# ssl_stapling_verify on; # Requires nginx => 1.3.7
# resolver $DNS-IP-1 $DNS-IP-2 valid=300s;
resolver_timeout 5s;
