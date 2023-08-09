server {
    listen 80;
    server_name testdomain2.ru;
    location / {
        index en_EN.html;
        root static;
    }
}
