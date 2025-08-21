services:
  db:
    image: postgres:15
    environment:
      POSTGRES_USER: keycloak
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
      POSTGRES_DB: keycloak
    volumes:
      - keycloak-db:/var/lib/postgresql/data
    networks: [app]

  keycloak:
    image: quay.io/keycloak/keycloak:latest
    command: >
      start --http-enabled=true
            --proxy-headers=xforwarded
            --hostname=https://${DOMAIN}
            --import-realm
    environment:
      KC_DB: postgres
      KC_DB_URL_HOST: db
      KC_DB_URL_DATABASE: keycloak
      KC_DB_USERNAME: keycloak
      KC_DB_PASSWORD: ${POSTGRES_PASSWORD}
      KC_BOOTSTRAP_ADMIN_USERNAME: ${KEYCLOAK_ADMIN}
      KC_BOOTSTRAP_ADMIN_PASSWORD: ${KEYCLOAK_ADMIN_PASSWORD}
      OIDC_CLIENT_SECRET: ${OIDC_CLIENT_SECRET}
      KC_HTTP_ENABLED: "true"
      KC_HOSTNAME_STRICT_HTTPS: "false"
    depends_on: [db]
    volumes:
      - ./keycloak/demo-realm.json:/opt/keycloak/data/import/demo-realm.json:ro
    networks: [app]

  oauth2-proxy:
    image: quay.io/oauth2-proxy/oauth2-proxy:v7.6.0
    environment:
      OAUTH2_PROXY_PROVIDER: oidc
      OAUTH2_PROXY_OIDC_ISSUER_URL: http://keycloak:8080/realms/demo
      OAUTH2_PROXY_CLIENT_ID: oauth2-proxy
      OAUTH2_PROXY_CLIENT_SECRET: ${OIDC_CLIENT_SECRET}
      OAUTH2_PROXY_COOKIE_SECRET: ${OAUTH2_PROXY_COOKIE_SECRET}
      OAUTH2_PROXY_EMAIL_DOMAINS: "*"
      OAUTH2_PROXY_REDIRECT_URL: http://${DOMAIN}/oauth2/callback
      OAUTH2_PROXY_REVERSE_PROXY: "true"
      OAUTH2_PROXY_SKIP_PROVIDER_BUTTON: "true"
      OAUTH2_PROXY_HTTP_ADDRESS: 0.0.0.0:4180
      OAUTH2_PROXY_UPSTREAMS: "file:///dev/null"
      OAUTH2_PROXY_INSECURE_OIDC_SKIP_ISSUER_VERIFICATION: "true"
    depends_on:
      keycloak:
        condition: service_started
    restart: unless-stopped
    networks: [app]

  web:
    image: nginx:alpine
    ports:
      - "443:443"
    depends_on: [oauth2-proxy, keycloak]
    restart: unless-stopped
    volumes:
      - ./web/nginx.conf:/etc/nginx/nginx.conf:ro
      - ./web/html:/usr/share/nginx/html:ro
      - /etc/letsencrypt:/etc/letsencrypt:ro
    networks: [app]

networks:
  app: {}

volumes:
  keycloak-db: {}
