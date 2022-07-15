
## MultiApp refactor

Renaming:

* dmarzi-app-web-01 => sol0-ilb-$APP_NAME-canary
* dmarzi-app-web-02 => sol0-ilb-$APP_NAME-prod
* dmarzi-apps-http  => sol0-ilb-$APP_NAME-http

Note that APPNAME confuses envsubst since its in .env.sh as Leucochrysos :/
=> I changed that locally in script 12 with some ugly chars hoping it wuld not pass k8s vet.
