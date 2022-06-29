after talking to dmarzi (go/ricc-dmarzi) we've agreed
to make it simpler and use WhereamI instead.

v1: https://paste.googleplex.com/5725534664261632#
v2: https://paste.googleplex.com/4692784813441024#
Gateway external https://paste.googleplex.com/5506650111737856

You need a cluster with GW API already enabled.

Creates:

* stoprev1/v2: pods/services
* store: MC, exists both here and there. Although n this case its useless.


# kubectl --context gke_cicd-platinum-test001_europe-west6_cicd-canary -n store get svc
# ubectl --context gke_cicd-platinum-test001_europe-west6_cicd-canary -n store get gateways
# kubectl --context gke_cicd-platinum-test001_europe-west6_cicd-canary -n store describe gateways/external-http => gives error