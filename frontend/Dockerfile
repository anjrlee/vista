# 使用 Nginx 官方映像
FROM nginx:alpine

# 把 Flutter Web build 複製到 Nginx html 資料夾
COPY build/web /usr/share/nginx/html

# 複製 Nginx 設定檔
COPY default.conf /etc/nginx/conf.d/default.conf
