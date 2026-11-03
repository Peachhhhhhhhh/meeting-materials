FROM nginx:1.27-alpine

ARG ENV=prod

ENV TZ=Asia/Shanghai \
    PORT=80

RUN apk add --no-cache tzdata && \
    cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo "Asia/Shanghai" > /etc/timezone && \
    apk del tzdata && \
    sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories && \
    apk add --no-cache curl

COPY public/ /usr/share/nginx/html/

COPY nginx.conf /etc/nginx/nginx.conf

RUN echo "server { \
    listen \$PORT; \
    server_name _; \
    root /usr/share/nginx/html; \
    index index.html; \
    charset UTF-8; \
    location / { \
        try_files \$uri \$uri/ /index.html; \
    } \
    location ~* \\.(html|js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf)$ { \
        expires 1y; \
        add_header Cache-Control \"public, immutable\"; \
    } \
}" > /etc/nginx/conf.d/default.conf

EXPOSE ${PORT}

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:$PORT/ || exit 1

CMD ["nginx", "-g", "daemon off;"]
