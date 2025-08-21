worker_processes auto;
events { worker_connections 1024; }
http {
  sendfile on;
  server {
    listen 443 ssl;
    server_name _;

    ssl_certificate     /etc/letsencrypt/live/${DOMAIN}/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/${DOMAIN}/privkey.pem;

    location /realms/ {
      proxy_pass       http://keycloak:8080/realms/;
      proxy_set_header Host $host;
      proxy_set_header X-Real-IP $remote_addr;
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_set_header X-Forwarded-Proto $scheme;
    }
    location /resources/ {
      proxy_pass       http://keycloak:8080/resources/;
      proxy_set_header Host $host;
      proxy_set_header X-Real-IP $remote_addr;
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_set_header X-Forwarded-Proto $scheme;
    }
    location = /oauth2/auth {
      proxy_pass       http://oauth2-proxy:4180/oauth2/auth;
      proxy_set_header Host $host;
      proxy_set_header X-Real-IP $remote_addr;
      proxy_set_header X-Scheme $scheme;
      proxy_set_header X-Auth-Request-Redirect $request_uri;
    }
    location /oauth2/ {
      proxy_pass       http://oauth2-proxy:4180;
      proxy_set_header Host $host;
      proxy_set_header X-Real-IP $remote_addr;
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_set_header X-Forwarded-Proto $scheme;
    }
    location / {
      auth_request /oauth2/auth;
      error_page 401 = /oauth2/start;
      root /usr/share/nginx/html;
      try_files $uri /index.html;
    }
  }
}
