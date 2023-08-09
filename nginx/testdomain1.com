server {
    listen 443 ssl;
    server_name testdomain1.com;
    ssl_certificate ssl/testdomain1.com/certificate.crt;
    ssl_certificate_key ssl/testdomain1.com/private.key;
    location ~* \.(jpg|jpeg|gif|png|ico|css|bmp|js|swf|avi|mp3|mpeg|wma|mpg|rar|zip)$ {
        root /home2/fa133445/testdomain1.com;
        try_files $uri =404;
    }
    location / {
        proxy_pass http://localhost:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
server {
    listen 80;
    server_name testdomain1.com;
    return 301 https://$host$request_uri;
}
