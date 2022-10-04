2022-10-04 v1.21.0  `v0.21.0` Docs freeze for publication and tagging. Now I'll test my code and ensure not to change
                    code until a fortunate dry run, so I can tag and promote this to `v1.0`.
2022-09-15 v0.20.3  Bug progress on `README` and some cleanup on scripts, or adding images.
2022-09-15 v0.20.2  Better `README` since a lot of googlers are now looking at my code.
2022-08-26 v0.20.1  Going through offical releasing (go/oss-your-code)
2022-08-26 v0.19.8  Minor fixes for prerelease `1.0alpha`
2022-08-26 release `1.0alpha`  https://github.com/palladius/clouddeploy-platinum-path/releases/tag/1.0alpha
2022-08-26 v0.19.7  Minor fixes for prerelease `1.0alpha`
2022-08-19 v0.19.6  Fixed _fatal in first 4 scripts. Should suffice.
2022-08-19 v0.19.5  sintactic sugar around solution4 (new vanilla sol1)
2022-08-19 v0.19.4  minor fixes from home
2022-08-19 v0.19.3  hidden app03 from most people :)
2022-08-19 v0.19.2  deprecated SMART_EGREP
2022-08-19 v0.19.1  [bielski] added app03 :)
2022-08-19 v0.19.0  Sol1 is now working!
2022-08-19 v0.18.13 Refactoring Fleet Membership only if needed since it took sa lot of time destroying and recretaing.
2022-08-19 v0.18.12 Reverting 0.18.10 change after bielski IAM fix for Artifact Repo
2022-08-19 v0.18.11 Added CLEANUP functionality for script 15/16 which is now inside 16 for simplicity.
2022-08-19 v0.18.10 Cloud Build script2: muted magic tagging as broken.
2022-08-19 v0.18.9  07.sh: only builds on MAIN branch.
2022-08-16 v0.18.7  01.sh: creates default network if it doesnt exist.
2022-08-16 v0.18.5  Started the #BigMerge for script 15 and 15b for #Solution2
2022-08-16 v0.18.4  Fixed big #CanProd2Dev4debug bug for real. Not fixing it would have been better actually :)
2022-08-15 v0.18.3  Trying to fix big #CanProd2Dev4debug bug
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
