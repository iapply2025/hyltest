#!/usr/bin/env bash
set -euo pipefail

az login --identity >/dev/null

export KEYCLOAK_ADMIN="$(az keyvault secret show -n KEYCLOAK-ADMIN --vault-name "$KV_NAME" --query value -o tsv)"
export KEYCLOAK_ADMIN_PASSWORD="$(az keyvault secret show -n KEYCLOAK-ADMIN-PASSWORD --vault-name "$KV_NAME" --query value -o tsv)"
export POSTGRES_PASSWORD="$(az keyvault secret show -n POSTGRES-PASSWORD --vault-name "$KV_NAME" --query value -o tsv)"
export OIDC_CLIENT_SECRET="$(az keyvault secret show -n OIDC-CLIENT-SECRET --vault-name "$KV_NAME" --query value -o tsv)"
export OAUTH2_PROXY_COOKIE_SECRET="$(az keyvault secret show -n OAUTH2-PROXY-COOKIE-SECRET --vault-name "$KV_NAME" --query value -o tsv)"

echo "Using DOMAIN=$DOMAIN"

envsubst < "$STACK_ROOT/docker-compose.yml.tpl" > "$STACK_ROOT/docker-compose.yml"
envsubst '${DOMAIN}' < "$STACK_ROOT/web/nginx.conf.tpl" > "$STACK_ROOT/web/nginx.conf"
envsubst < "$STACK_ROOT/keycloak/demo-realm.json.tpl" > "$STACK_ROOT/keycloak/demo-realm.json"

cd "$STACK_ROOT"
docker compose pull
docker compose up -d

echo "Finalize complete."
