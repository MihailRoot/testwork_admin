server {
    listen 80;
    server_name shop.testdomain1.com;
    location ~* \.(jpg|jpeg|gif|png|ico|css|bmp|js|swf|avi|mp3|mpeg|wma|mpg|rar|zip)$ {
        root /home2/fa133445/shop.testdomain1.com;
        try_files $uri =404;
    }
    location / {
        proxy_pass http://localhost:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
