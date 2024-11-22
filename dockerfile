FROM nginx:alpine

RUN mkdir -p /usr/share/nginx/html/page1 /usr/share/nginx/html/page2 /usr/share/nginx/html/images

COPY src/page1/index.html /usr/share/nginx/html/page1/
COPY src/page2/index.html /usr/share/nginx/html/page2/
COPY images/*.jpeg /usr/share/nginx/html/images/

# Update NGINX configuration to listen on port 8080
RUN sed -i 's/listen\s*80;/listen 8080;/g' /etc/nginx/conf.d/default.conf

EXPOSE 8080

CMD [ "nginx", "-g", "daemon off;" ]