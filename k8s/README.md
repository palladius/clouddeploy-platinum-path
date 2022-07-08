

## Solution0 - Gateway API + TS (internal IP only (*))

This solution was the first which came out. While it solves ALL problems, it only supports
internal IP. This is the *best* solution if you don't want a pu

+ Gateway API
+ Traffic Splitting
+ Multicluster
- no External IP (coming soon but now available now)

To make this solution work, you need a last-mile configuration which connects the ILB from 
This is super-new technology called Private Service Connect (PSC, [1]). To do so you need to additionally:

1. Create a Private Service Connect with consumer HTTP(S) service controls
([2] basically a link between two VPCs: one with your ILB and one with XLB).
1. Create a new PSC Network Endpoint Group (NEG) which links to the ILB.
1. Create External Load Balancer on top of the PSC NEG.

For more info:

* [1] https://cloud.google.com/vpc/docs/private-service-connect 
* [2] https://cloud.google.com/vpc/docs/configure-private-service-connect-controls

Thanks Roberto for this.

# solution1 - GXLB (Classic) + Gateway API (no TS)

+ GatewayAPI (idiomatic - everything is a k8s manifest)
+ Classic External Load Balancer
+ No Traffic splitting -> Pod splitting achieved with 9 vs 1 pods (made easy via kustomize).
- Needs 

# Solution2 - GXLB (new envoy based) + Traffic Splitting (requires gcloud plumbing)

+ New envoy-based External Load Balancer
+ Supports Traffic Splitting in LB
- requires some significant work on gcloud so it's not pure k8s idiomatic (knative would say boooh).



## other info

This is generic/global GKE/k8s setup. For specific setup of apps (app01, ..), look under these folders:

* apps/app01/k8s/...
* apps/app02/k8s/...

Currently its being migrated to Kustomize and there are some duplicates in the code. Apologies about it. for instance, there is kustomize code in both folders:

* `apps/components/`
* `components/`

How inconsiderate of me.