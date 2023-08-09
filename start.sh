#!/bin/bash

STATIC_DIR="static"
NGINX_DIR="nginx"
SSL_DIR="ssl"
APACHE_PORT="8080"

while read y
do
    if [[ "${y:0:1}" != "#" ]]; then
        var1=$(echo $y | cut -d' ' -f1)    
        var2=$(echo $y | cut -d' ' -f2)    
        var3=$(echo $y | cut -d' ' -f3)  
        var4=$(cat domains_ssl.list | grep $var3 | cut -d' ' -f1)
        var5=$(cat domains_ssl.list | grep $var3 | cut -d' ' -f2)
        useradd -d "$var2" "$var1" > /dev/null 2>&1

        if [[ $var4 != ""  ]];then
            if [[ $var5 == '1' ]]; then
                
                cat << EOF> $NGINX_DIR/$var3
server {
    listen 443 ssl;
    server_name $var3;
    ssl_certificate $SSL_DIR/$var3/certificate.crt;
    ssl_certificate_key $SSL_DIR/$var3/private.key;
    location ~* \.(jpg|jpeg|gif|png|ico|css|bmp|js|swf|avi|mp3|mpeg|wma|mpg|rar|zip)$ {
        root $var2/$var3;
        try_files \$uri =404;
    }
    location / {
        proxy_pass http://localhost:$APACHE_PORT;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }
}
server {
    listen 80;
    server_name $var3;
    return 301 https://\$host\$request_uri;
}
EOF
            else
                cat << EOF> $NGINX_DIR/$var3
server {

    listen 80;
    server_name $var3;
    location ~* \.(jpg|jpeg|gif|png|ico|css|bmp|js|swf|avi|mp3|mpeg|wma|mpg|rar|zip)$ {
        root $var2/$var3;
        try_files \$uri =404;
    }
    location / {
        proxy_pass http://localhost:$APACHE_PORT;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }
}
server {
    listen 443 ssl;
    server_name $var3;

    ssl_certificate $SSL_DIR/$var3/certificate.crt;
    ssl_certificate_key $SSL_DIR/$var3/private.key;

    location / {
        proxy_pass http://localhost:80;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }
}
EOF
                
            fi
        else
            cat << EOF> $NGINX_DIR/$var3
server {
    listen 80;
    server_name $var3;
    location ~* \.(jpg|jpeg|gif|png|ico|css|bmp|js|swf|avi|mp3|mpeg|wma|mpg|rar|zip)$ {
        root $var2/$var3;
        try_files \$uri =404;
    }
    location / {
        proxy_pass http://localhost:$APACHE_PORT;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }
}
EOF

        fi
    fi
done < domains.list

#ddos
while read y
do
    if [[ "${y:0:1}" != "#" ]]; then
        cat << EOF> $NGINX_DIR/$y
server {
    listen 80;
    server_name $y;
    location / {
        try_files  =503;
    }
}
EOF
    fi
done < ddos.list

#suspend
while read y
do
    if [[ "${y:0:1}" != "#" ]]; then
        var1=$(echo $y | cut -d' ' -f1)    
        var1=$(cat domains.list | grep $var1 )
        var2=$(echo $y | cut -d' ' -f2)  
        while IFS= read -r line
        do
            if [[ "${line:0:1}" != "#" ]]; then
                var3=$(echo $line | cut -d' ' -f3)  
                cat << EOF> $NGINX_DIR/$var3
server {
    listen 80;
    server_name $var3;
    location / {
        index $var2.html;
        root $STATIC_DIR;
    }
}
EOF
            fi
        done <<< "$var1"  

    fi
done < suspend.list

systemctl reload nginx