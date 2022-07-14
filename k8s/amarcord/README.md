This is a link to original code which I'm not going to touch, for study purposes.

* solution0 - 13jun22 - 11-enable-Gateway-API-within-GKE.sh - https://github.com/palladius/clouddeploy-platinum-path/pull/3/files
* solution1 - 28jun22 - NO SHELL :) - https://github.com/palladius/clouddeploy-platinum-path/pull/5 https://github.com/palladius/clouddeploy-platinum-path/pull/6
* solution2 - 4jul22 -  k8s/xlb-gfe3-traffic-split/ - https://github.com/palladius/clouddeploy-platinum-path/pull/7

# More on sol0/3 (First PR)

Raw file sol0: https://raw.githubusercontent.com/palladius/clouddeploy-platinum-path/77bfd6ea483f0fcd6f27a4062fd65ab6595135e0/11-enable-Gateway-API-within-GKE.sh

Step 4. YOu have 2 clusters, you can enable one or 2. you can also enable just 1.
Traffic will flow to both, but if u choose 1 google uses only that 1 for control plane.
So its a bit more elagnt to have in 2 for HA but not necessary.

MULTI_APP:
* kind: Gateway: UNO only one gateway
* Srv (exposes app) /SrvExp (MCS - exposes srv oltre proprio cluster ). uno per servizio _TWO_ $$NN
* HTTPRoute: one per app.

# More on sol ONE (2nd PR) (gke-l7-gxlb) pod-splitting

Here you just have to install the Gateway API -> CRD 4.3 e that's it.
No more `gcloud` plumbing.

Two pull requests:

1. Jun 28: https://github.com/palladius/clouddeploy-platinum-path/pull/5/files?diff=unified&w=0 Created k8s/dmarzi-xlb-canary/ with 4 files:

* NEW README.md
* NEW app-v1.yml
* NEW app-v2.yml
* NEW gateway.yml

2. Jun 29: https://github.com/palladius/clouddeploy-platinum-path/pull/6

* CNG gateway.yml https://github.com/palladius/clouddeploy-platinum-path/blob/95e6d8a8b09c1a3b37087db48a4362cf180c9916/k8s/dmarzi-xlb-canary/gateway.yml
* NEW route.yml https://github.com/palladius/clouddeploy-platinum-path/blob/95e6d8a8b09c1a3b37087db48a4362cf180c9916/k8s/dmarzi-xlb-canary/route.yml
* NEW service-common.yml


NOTA Daniel: you have everything except Deployments of apps, che posso prendere da ILB.
Service has been configured as in (0) as is:

For canary:

    app: store
    version: v1

For prod:

    app: store
    version: v2

NEG: __MULTI__ but you can also remove the name and he'll figure it out for you.


## Solution2

TODO - just copied from here:

* BRANCH: https://github.com/palladius/clouddeploy-platinum-path/tree/dmarzi/xlb-gfe3-traffic-split/k8s
* subfolder: 8s/xlb-gfe3-traffic-split
