FROM nginx
LABEL maintainer test
RUN rm -rf /usr/share/nginx/html/*
ADD docs/* /usr/share/nginx/html/