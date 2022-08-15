This folder contains scripts which derail a bit from original intent of
this.

* The terraform script is half-baked. I'll promote to root folder only AFTER
  terraforming EVERYTHING, which might not happen soon.

* The Cloud DNS part is amazing and wors fine, but requires you to do the initial heavy lifting. Once you bring your DNS to Google Cloud, my scripts
can help you get the IP for a service and remove the `-H` from your curls :)

* 11/12 solution0. This is an AMAZING Internal Load Balancer solution. However, I wasn't able to expose the internal
  service in any way. The Envoy-based ILB wants a proxy subnet where you can't just create GCE VMs. So the service might
  as well work flawlessly but there's no way for me to test it :)
