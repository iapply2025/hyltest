{
  "realm": "demo",
  "enabled": true,
  "clients": [
    {
      "clientId": "oauth2-proxy",
      "protocol": "openid-connect",
      "publicClient": false,
      "redirectUris": ["https://${DOMAIN}/oauth2/callback"],
      "webOrigins": ["https://${DOMAIN}", "http://localhost", "*"],
      "attributes": { "post.logout.redirect.uris": "https://${DOMAIN}/" },
      "secret": "${OIDC_CLIENT_SECRET}"
    }
  ],
  "users": [
    {
      "username": "demo",
      "enabled": true,
      "firstName": "Demo",
      "lastName": "User",
      "email": "user@example.com",
      "emailVerified": true,
      "credentials": [{ "type": "password", "value": "change_me", "temporary": true }]
    }
  ]
}
