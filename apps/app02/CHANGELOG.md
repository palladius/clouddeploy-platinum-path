* 2022-10-24 v2.1.0 [DEV] IMPORTANT: from now it logs statusz content for both endpoints
* 2022-10-24 v2.0.9 [DEV] After Will PR #33 merge.
* 2022-08-16 v2.0.8 [DEV] Scrambling /statusz order which seems to make more sense.
* 2022-08-16 v2.0.7 [DEV] Simple bump with update of docs, nothing more.
* 2022-07-23 v2.0.5 [DEV] v2-0-5slashn commit 30163926b67c04b4232da94b19b79f8d034d4b83 fixed the \n in /statusz
* 2022-07-19 v2.0.3 [DEV] BugFix: KeyError at /
                    key not found: "CLOUD_DEPLOY_TARGET_COMMON" Did you mean? "CLOUD_DEPLOY_TARGET_SHORT_COMMON"
                    file: sinatra.rb location: fetch line: 54
* 2022-07-19 v2.0.2 [DEV] Shortened target thanks to leveraging CLOUD_DEPLOY_TARGET_SHORT_COMMON
* 2022-07-19 v2.0.0 [DEV] Added /statusz for easy grepping. Damn I needed to change EVERYTHING and move to Sinatra. Upgraded to 3 numbers now :)
* 2022-07-18 v1.30  [DEV] fixed emoji: https://stackoverflow.com/questions/34621541/why-dont-emojis-render-in-my-html-and-or-php
* 2022-07-18 v1.29  [DEV] Added /statusz for easy grepping. nice ENv from Makefile.
* 2022-07-18 v1.28  [DEV] fixed env, removed RICCARDO_KUSTOMIZE_ENV and added CloudDeploy env vars.
* 2022-07-18 v1.27  [DEV] now we have 4 colors, one per different Target. This makes it easy to troubleshoot on Web page.
* 2022-07-16 v1.23  [OPS] fixed dockerfile to serve on 8080. NOW it should work!
* 2022-07-16 v1.22  [OPS] moved Depl from 80 to 8080 so now its the same as Python app. Could help my scripts :)
* 2022-07-15 v1.12  [OPS] moved prod -> production in skaffold stage to match CloudDeploy.yaml
* 2022-07-14 v1.11  [OPS] removed namespaces from all targets!
* 2022-06-14 v1.8   Added ruby gem emoji ❤️ to HTMl and cleaned up the APP_NAME
* 2022-06-10 v1.7   Added ENV[APP_NAME] to HTML
* 2022-06-10 v1.6   just version bump to test
* 2022-06-10 v1.5   (or maybe 1.4?) Added ENV[APP_NAME] logic, to then add to HTML
