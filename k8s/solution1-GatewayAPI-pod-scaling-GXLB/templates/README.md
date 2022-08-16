Substitutions for tomorrow after Seeuberquaerung:

* v1 => canary
* v2 => prod
* store => "__PREFIX__-sol1"
* bifid-external-store => "__PREFIX__-sol1-ext"
* selector: "app: store" => ricc-awesome-selector: canary-or-prod

# 2022-07-18

* changed __PREFIX__sol1- to sol1-__PREFIX__- since there's a issing dash anyway and all sol2 start with sol2.

# 2022-07-20

* changed all `external-store-http` to `sol1-__PREFIX__-xgw` (was ext-gw)
* changed all `store-common-svc` to `sol1-__PREFIX__-common-svc`

# 2022-07-21

After talking to Daniel, started the `sol1-` to `sol1d-` rename.
More info in https://github.com/palladius/clouddeploy-platinum-path/issues/22

* changed all `sol1-` to `sol1d-`
* changing pointer from `ricc-awesome-selector: canary-or-prod` to `dev-or-staging`

# 2022-08-15

* moved so0l1d to sol1a.
* leaving sol1d in DEV under tmp/ folder (not checked in :/ )
* moving back to CAN/PROD for the selector, so now I hacve TMP/ pointing to dev and TEMPLATES/ pointing to CANPROD.

# 2022-08-16

* moving back to SOL1D but renaming to SOL1SC (to signify Single cluster)
