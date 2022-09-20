This folder contains scripts which derail a bit from original intent of
this.

* The terraform script is half-baked. I'll promote to root folder only AFTER
  terraforming EVERYTHING, which might not happen soon.

* The Cloud DNS part is amazing and wors fine, but requires you to do the initial heavy lifting. Once you bring your DNS to Google Cloud, my scripts
can help you get the IP for a service and remove the `-H` from your curls :)

* 11/12 solution0. This is an AMAZING Internal Load Balancer solution. However, I wasn't able to expose the internal
  service in any way. The Envoy-based ILB wants a proxy subnet where you can't just create GCE VMs. So the service might
  as well work flawlessly but there's no way for me to test it :) A good way to check solution0, try this:

```
gcloud compute instances create ilb0-sbirciatina --project=cicd-platinum-test002 --zone=europe-west1-b --machine-type=e2-medium --network-interface=subnet=default,no-address --maintenance-policy=MIGRATE --provisioning-model=STANDARD --service-account=577707369531-compute@developer.gserviceaccount.com --scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/trace.append --create-disk=auto-delete=yes,boot=yes,device-name=ilb0-sbirciatina,image=projects/debian-cloud/global/images/debian-11-bullseye-v20220719,mode=rw,size=10,type=projects/cicd-platinum-test002/zones/us-central1-a/diskTypes/pd-balanced --no-shielded-secure-boot --shielded-vtpm --shielded-integrity-monitoring --reservation-affinity=any
```
