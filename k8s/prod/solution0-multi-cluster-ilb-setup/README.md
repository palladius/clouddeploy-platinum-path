# solution 0 (Internal Load Balncer) 

This solution supports Traffic Splitting and multicluster but supports no External IP.


This set up is needed to set up the GKE cluster in canary mode.
Basically we want to Load Balance acrossw Canary (90%) and Prod (10%)
creating a 'static' balancer which balances across those resources. To make this
a bit more complicated, this is a cross-cluster balancer :)


## Docs

* https://cloud.google.com/kubernetes-engine/docs/how-to/multi-cluster-services

## Thanks

* Thanks to Daniel Marzini for immense help