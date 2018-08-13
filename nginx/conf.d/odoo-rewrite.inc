# disable website info
location /website/info {
    rewrite /website/info /website last;
}
