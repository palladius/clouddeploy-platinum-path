2022-08-15 v0.18.2  Fixed big #CanProd2Dev4debug bug
2022-08-15 v0.18.2  Obsoleted solution 0/3. There can be only.. 2! :)
2022-08-15 v0.18.1  Renamed consistently `dmarzi-proxy` to `platinumn-proxy`
2022-08-   v0.18.0  Back from OOO. Now coding the 6.5 solution leveraging Cloud Build’s new Repos API.
2022-07-22 v0.17.2  Last day before holidays. Seems like I might be able to fix SOL2 in extremis before OOO?!?
2022-07-21 v0.17.0  Moving clusters to Standard, no autpilot. Why? The first few hours it fails to deploy and its bad for
                    a demo. Cheaper on the long run, but more frustrating at the beginning.
2022-07-20 v0.16.0  Fixed solution1 (was pointing to canary/dev for debug, now moved to canary/prod)
2022-07-19 v0.15.0  Bringing clarity and cleanliness after Hurricane Alex: https://github.com/palladius/clouddeploy-platinum-path/issues/18
2022-07-19 v0.14.0  Substantially changed the code for Solution ONe. I've done two BIG things:
                    1. Looked at all the code here: https://github.com/palladius/clouddeploy-platinum-path/tree/main/k8s/amarcord/original-solution1-dmarzi/_ORIGINAL
                    2. Also changed bname to GatewayClassName to 'gke-l7-gxlb'
2022-07-18 v0.13.1  Solution1 pretty much refactored. Many sol1 put ast beginning, also added where they didnt exist before (big bug fixed).
                    Plus using "ricc-env: staging" vs "stage: canary" which didnt work at all!
2022-07-18 v0.13.0  Script 15.sh is now fully multitennant! Plus I've added to Common Templates the COMMON stage.
2022-07-17 v0.12.0  Fixed script 15.sh finally!
