server {
    listen 80;
    server_name mysite.com.ru;
    location / {
        index ru_RU.html;
        root static;
    }
}
