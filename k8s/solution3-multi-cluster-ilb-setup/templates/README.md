
## MultiApp refactor

Renaming:

* dmarzi-app-web-01 => sol0-ilb-$APPNAME-canary
* dmarzi-app-web-02 => sol0-ilb-$APPNAME-prod
* dmarzi-apps-http  => sol0-ilb-$APP_NAME-http

Note that APPNAME confuses envsubst since its in .env.sh as Leucochrysos :/
