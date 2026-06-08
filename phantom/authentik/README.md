# Authentik

## JWT

Some services have an API that is protected by Authentik. To configure personal applications with those services, you'll need a JWT that can be used as a Bearer token.

1. Obtain the _Client ID_ from the _Proxy Provider_ at _Applications / Providers / Provider / Authentication_.
2. Use your username or a service account's username.
3. Create an _App Password_ at <https://authentik.example.org/if/user/#/settings;%7B%22page%22%3A%22page-tokens%22%7D>.
4. Update the _Token validity_ of the _Proxy Provider_ at _Applications / Providers / Provider / Edit_ to something like `days=36524`.
5. Request your new JWT:

   ```sh
   curl 'https://authentik.example.org/application/o/token/' \
     -H 'Content-Type: application/x-www-form-urlencoded' \
     --data-urlencode 'grant_type=client_credentials' \
     --data-urlencode "client_id=$CLIENT_ID" \
     --data-urlencode "username=$USERNAME" \
     --data-urlencode "password=$PASSWORD"
   ```

   You should get something like this:

   ```json
   {
   	"access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWUsImlhdCI6MTUxNjIzOTAyMn0.KMUFsIDTnFmyG3nMiGM6H9FNFUROf3wh7SmqJp-QV30",
   	"token_type": "Bearer",
   	"scope": "",
   	"expires_in": 3155695200,
   	"id_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWUsImlhdCI6MTUxNjIzOTAyMn0.KMUFsIDTnFmyG3nMiGM6H9FNFUROf3wh7SmqJp-QV30"
   }
   ```

6. Change back your _Token validity_ to something more reasonable, like `days=1`.
7. Use the `access_token` as your Bearer token. If your application only supports basic auth, then use `goauthentik.io/token` as the username.

For more information, see <https://docs.goauthentik.io/add-secure-apps/providers/proxy/header_authentication>.
