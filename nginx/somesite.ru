server {
    listen 80;
    server_name somesite.ru;
    location / {
        try_files  =503;
    }
}
