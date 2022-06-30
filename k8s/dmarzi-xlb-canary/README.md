# GXLB 

Daniel wrote:

GXLB manage traffic but cannot manage traffic splitting

In this example, in order to check the canary deployment, the /canary url should be used.

* normal traffic: `curl -H "host: store.example.io" VIP/`
* canary traffic: `curl -H "host: store.example.io" VIP/canary`

## tests clusters:

* Daniel:  `canary-noauto`
* Ricc: STATIC (`cicd-noauto-dev`) 
* Ricc: AUTOPILOT (`cicd-canary`)  

## Gateways

```
$ gcloud compute forwarding-rules list | grep gkegw 
gkegw1-jkyr-default-bifid-external-store-http-7cy2x33maug5                34.117.59.54    TCP          gkegw1-jkyr-default-bifid9010-prod-web-gw-q6mrsmmslexp                    34.111.12.6     TCP          gkegw1-jkyr-default-external-store-http-4vkl7p6d01em                      34.117.146.93   TCP          gkegw1-jkyr-default-ricc-external-store-http-w375rjuap63f                 34.117.142.130  TCP          gkegw1-oy52-default-external-store-http-4vkl7p6d01em                      34.149.231.48   TCP          
```

DNSs