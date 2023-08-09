server {
    listen 80;
    server_name testdomain1.ru;
    location / {
        index en_EN.html;
        root static;
    }
}
