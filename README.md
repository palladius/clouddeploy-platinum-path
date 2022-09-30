# 🐤 Canary Solutions with GCP Cloud Deploy

Self: https://github.com/palladius/clouddeploy-platinum-path

Article on Medium: https://medium.com/@palladiusbonton/draft-canarying-on-gcp-with-cloud-deploy-91b3e4d0ee9a

This repo tries to demo a few applications (under `apps/`) and it's path to
deployment via Google Cloud Platform's `Cloud Build` + `Cloud Deploy`.
Since a lot of setup is needed, I took inspiration from `[willisc7](https://github.com/willisc7)`'s
[Gold Path repo](https://github.com/willisc7/next21-demo-golden-path).

I've tried to simplify the app and the `skaffold` part and concentrated on
automating the installation of Service Accounts, clusters, etc. all in
single scripts with a catchy name.

Note that EVERYTHING is automated except linking the external repo to Cloud
Build (this is currently possible in Alpha API which requires whitelisting).
All the shell scripts you see in the main directory have been
extensively tested, all the experimental code is under
[examples/](https://github.com/palladius/clouddeploy-platinum-path/tree/main/examples).

**This is _NOT_ an officially supported Google product.**

## High-level architecture

<img src="https://github.com/palladius/clouddeploy-platinum-path/blob/main/doc/Ricc%20Canary%20deployment%202022.png" alt="Architecture v1.1" align='right' />

## Setting things up

All scripts in the root directory are named in numerical order and describe the outcome they’re intended to achieve.

Before executing any bash script, they all source a `.env.sh` script which you’re supposed to create (from the
`.env.sh.dist` (file) and maintain somewhere else (I personally created and use
[git-privatize](https://github.com/palladius/sakura/blob/master/bin/git-privatize)
and symlink it from/to another private repo).

1. Choose your environment.
    * You can use Google [Cloud Shell](https://cloud.google.com/shell) 🖥️ (leveraging the awesome integrated editor).
      This code has been fully tested there.
    * **Linux** machine where you’ve installed `gcloud`.
    * **Max OSX** with bash v5 or more (to support hashes). To do so, just try `brew install bash` and make sure to use
      the new BASH path ~(you might have to explicitly call the scripts with `bash SCRIPTNAME.sh`).

2. [Fork](https://github.com/palladius/clouddeploy-platinum-path/fork) the code repo:
    * Go to https://github.com/palladius/clouddeploy-platinum-path/
    * Click “**Fork”** to fork the code under your username.


    TODO(github scrreenshot image)

   * New URL will look like this: https://github.com/daenerys/clouddeploy-platinum-path [with your username].
     You’ll need this username in a minute.
   * **__Note__** that if you don’t have a github account (and you don’t want to create one), you can just fork my repo in your
     GCR - more instructions later at step (6) below.
   * To connect your github repo, follow instructions here: https://cloud.google.com/build/docs/automating-builds/github/build-repos-from-github
   * Open **Cloud Developer Console** > **Cloud Build** > **Triggers**: https://console.cloud.google.com/cloud-build/triggers
   * Click on **Connect repository** button (bottom of page):

     TODO(connect repository image with arrow)

    * “Select Source” > “**GitHub (Cloud Build GitHub App)**” and click “continue”.


3. [Totally optional] Install a colorizing gem. If you won’t do it, there’s a `lolcat` fake wrapper in `bin/` (added to
   path in init script). But trust me, it’s worth it (unless you have no Ruby installed).

    gem install lolcat


4. Copy the env template to a new file that we’ll modify

    cp .env.sh.dist .env.sh

5. Open `.env.sh` and substitute the proper values for any variable that has # changeme next to it.
  (If you’re on 🖥️ **Cloud Shell**, you can try `edit .env.sh` 😎 to let the UI editor shine). For instance:

    * **PROJECT_ID**. This your string (non-numeric) project id -
      [More info](https://cloud.google.com/resource-manager/docs/creating-managing-projects).
    * **ACCOUNT** (eg, john.snow.kotn@gmail.com). This is the email address of your GCP identity (who you authenticate
      with). Note that you can also set up a service account, but that’s not covered by this demo. In this case I’ll leave
      it with you to tweak the 00-init.sh script. On 🖥️ Cloud Shell, it's already set and you can get it from
      `gcloud config get account`.
    * **GCLOUD_REGION**. This is the region where 90% of things will happen. Please do choose a region with more
      capacity (my rule of thumb is to choose the oldest region in your geo, like us-central1, europe-west1, …).
      If unsure, pick our favorite: us-central1.
    * **GITHUB_REPO_OWNER** (eg, *“daenerys”*). This should be the user you forked the repo with in step (2). You can
      find it also in `$ grep clouddeploy-platinum-path .git/config`

Optional fields:


* **GCLOUD_CONFIG** [optional]. This is the name of your gcloud configuration. Pretty cosmetic, it becomes important
  when you have a lot of users/projects for different projects and you want to
  📽️ [keep them separated](https://www.youtube.com/watch?v=1jOk8dk-qaU). Try
  `gcloud config configurations list` to see your local environment. While not needed, I consider it a good practice to
  isolate your configs into gcloud configs.

* **MY_DOMAIN** [optional]. This is totally optional. Setting up [Cloud DNS](https://cloud.google.com/dns)
  is very provider-dependent. If you have Cloud DNS already set up, you can be inspired by my script in
  `examples/14-setup-DNS-Riccardo-only.sh` and tweak it to your liking.


6. Tip (*optional*): If you want to persist your personal `.env.sh`, consider using my script `git-privatize`. If  you
   find a better way, please tell me - as I’ve looked for the past 5 years and this is the best I came up with.

### First - a note on my scripts

The root directory of my repo has a number of bash scripts which could discourage most of you. A few technical and philosophical notes:
* Scripts must be run in alpha order from `00-XXX.sh` to `16-YYY.sh`.
* Every script is “transactional”, meaning if fails at first non-0 exit of a subcommand (this is achieved by `set -e` plus
  `bin/proceed_if_error_matches` for which I've been nominated for a Pulitzer). At the end of the script, a common
  routine will touch a file called `.executed_ok.04-status.sh.touch`. This will leave a breadcrumb trail which tells you
  where the script failed:

  TODO(ricc): image on breacrumbs

* Everything in this is scripted except one point which requires manual intervention between step 6 and step 7, which
  is why I called the manual intervention 6.5 which I then moved at the beginning of the instructions (so now it looks
  more lie 0.065).

### Scripts from 1 to 16

0. `00-init.sh`. **Initialization**

  This scripts parses the ENV vars in env.sh and sets your GCLOUD, SKAFFOLD and GKE environment for
  success. If you leave this project, do something else with gcloud or GKE and come back to it tomorrow, its always safe
  to execute it once or even twice.

    🐧ricc@derek:~/clouddeploy-platinum-path$ ./00-init.sh

1. (`./01-set-up-GKE-clusters.sh`).  **Setting up GKE clusters**

  This script sets up 3 autopilot clusters:

* cicd-noauto-canary. It will contain canary workloads (pre-prod)
* cicd-noauto-prod. It will contain production workloads.
* cicd-noauto-dev. It will contain everything else (dev, staging, and my tests). It will also be the *default* cluster.

Note:  Cluster Build can take several minutes to complete. You can check progress by viewing the
`Kubernetes Engine` -> `Kubernetes clusters` screen, or just have a ☕.


2. `./02-setup-skaffold-cache-bucket.sh` **Setup GCS + Skaffold Cache**.

   This script creates a bucket which we'll use as Skaffold
   Cache. This will make your Cloud Builds super-fast! Thanks Alex the tip!



3. boh
4. todo
5. todo
6. todo
7. todo
8. todo
9. todo
10. todo
11. todo
12. todo
13. a
14. a
15. `15-solution2-xlb-GFE3-traffic-split.sh` **Set up traffic split (solution 2!)**

TODSO(text): at least i put the image

<img src="https://github.com/palladius/clouddeploy-platinum-path/blob/main/doc/app02-sol2-svc-canaryprod-neg-view.png?raw=true" alt="Solution 2 NEG view on GCP GCLB page" align='center' />


16. a






## Other great scripts

I've disseminated `bin/` with scripts that I utilized for testing my solutions. You might find them useful (and send me
a PR to fix the errors ). Some examples:

    🐧ricc@derek:$ bin/curl-them-all

<img src="https://github.com/palladius/clouddeploy-platinum-path/blob/main/doc/curl-them-all-screenshot.png?raw=true" alt="curl-them-all script example" align='center' />


## Express Install

* Make sure you did the mirrot github repo and your github user is in your env.sh.
* Do steps 1,2,3,4,5,6 automatically: `make first-half` (should ~always work)
* Do steps 7,8,9,..,16 automatically - `make second-half` (can fail if you made mistake in the mirror repo setup)

You should be good to go!

Note: Some scripts in here can all be found
in my [Swiss-Army Knife repo](https://github.com/palladius/sakura/), but the ones needed
for this are all under `bin/`.

## The apps

The app part is really the NON-interesting part here. I tried to keep it as simple as
possible. You can complicate it as long as you have a Dockerfile or a Buildpack
to build it.

* `apps/app01/` This is a sample 🐍 *Python* app.
* `apps/app02/` This is a sample 💎 *Ruby* app.
* `apps/app03/` This is a sample 🧊 *Node.js* app.

<img src="https://github.com/palladius/clouddeploy-platinum-path/blob/main/doc/3apps.png?raw=true" alt="Three Apps" align='center' />

They both expose a single Web page (`/`) with a lot of debug useful information, usually
surfaced by proper ENV vars. They also expose a second convenience endpoint (`/statusz`)
with a one-liner description (used by scripts), such as:

```
app=app01 version=2.23 target=prod emoji=🐍
app=app01 version=2.22 target=canary emoji=🐍
[..]
app=app02 version=2.0.6 target=prod emoji=💎
app=app02 version=2.0.7 target=canary emoji=💎
[..]
app=app03 version=1.0.2 target=prod emoji=🧊
app=app03 version=1.0.3 target=canary emoji=🧊
```

<img src="https://github.com/palladius/clouddeploy-platinum-path/blob/main/doc/canary-horizontal-render.gif?raw=true" alt="Terminal Demo" align='center' />

## Build philosophy

* Every commit to `main` will trigger a Cloud Build, provided code is in some `apps/appXX/` . In particular, any change to the code to app01 will trigger a build in the APP01 pipeline, and so on. **Yes**, it's that beautiful.

* Promotion DEV -> STAGING. This is a second BUILD which also executes `make test` in the
`app/MYAPP` folder.

* *For picky people*. Note that in the real world, the promotion from DEV to STAGING wouldn't happen after Unit Tests (rather integration tests), but for this demo I wanted as many releases out as possible with minimal manual intervention, so I did it this way. In a real scenario, a failed `make test` would prevent the DEV release altogether.

## Deploy philosophy

4 targets have been created:

1. **dev**. Every successful commit lands here. Deploys to **dev** GKE cluster.
1. **staging**. Also deploys to **dev** GKE cluster.
1. **canary** *OR* **canary-production** (depends on app, see below). A release in this state will get a small
  percentage of traffic.
2. **production**. A release in this state will get *most* traffic. Deploys to **prod** GKE cluster.

Note on apps and third stage (*canary**):

* **App01**🐍 and **App02**💎 have **canary** as 3rd stage, which pushes to a **canary** GKE cluster.
  This has been done to demonstrate a complex, multi-cluster case.
* **App03**🧊 been configured differently with **canary-production** as 3rd stage , with Canary and Production stages
  *both* pushing to prod GKE cluster. This has been done to demonstrate a simpler use case.

Confused? See this graph:

<img src="https://github.com/palladius/clouddeploy-platinum-path/blob/main/doc/bifid tetra-pipeline.png?raw=true" alt="Four targets, 2 solutions depending on app" align='center' />


## Canary solutions

Historically, 3 solutions have been provided. History is important since it plays a role
into script numbering and ordering ;) which was hard to change. A fourth solution has been added in July 22.

* ❌ ~~Solution0: ILB + TrafficSplitting. Doesnt have public IP.~~ [Initial code (script 11)](https://github.com/palladius/clouddeploy-platinum-path/pull/3/files)
* ❌ ~~Solution1: Global XLB + Gateway API + Pod splitting.~~
* ✅ **Solution2**: Envoy-based GXLB + Gateway API +proper Traffic Splitting (**complex solution**) (for `app01` and `app02`).
* ❌ ~~Solution3: *symlink* to solution0~~
* ✅ **Solution4** (**simple solution**): single-cluster Pod Splitting (`app03`).

More info on historical code under `k8s/amarcord/` (Romagnolo Italian for *I remember*, plus a
[memorable movie by Federico Fellini](https://en.wikipedia.org/wiki/Amarcord)).

*(GXLB: Global eXternal Load Balancer)*

### Simple solution: single-cluster pod-splitting (🟢🟢🟢🟢🟡) thru k8s service

*(formerly known as: Solution 4)*

TODO(ricc): images

### Complex solution: multi-cluster traffic-splitting canarying through Gateway API , envoy-backed ⚖️ XLB and 🪡 lot of weaving

*(formerly known as: Solution 2)*

This is what you'll see when you get this to work:

<img src="https://github.com/palladius/clouddeploy-platinum-path/blob/main/doc/solution2 app01 python sample.png?raw=true" alt="Solution 2 example" align='center' />

## Lesson learnt

* Never EVER change name of entities, particularly if they are pointed by different products/modules.
  for instance, the Artifact Repository, or the Image name. Image version is a no-breezer, but remember
  that changing the code in your manifest doesn't mean that the deployer is aware of the change because
  its configuration "online" is based on a 1-month-old manifest which pointed to the earliest version.
  If you do, destroying everything and rebuilding seems the only safe choice, and since I don't want it
  I suggest you: don't change the NAMES, change just everything else :)
* As a corollary, when you name a resource, make sure you spend **time** to add the right dimensions: is it
  function of APPNAME? If yes, it should have APPNAMe inside the name (like "appo1-frontend"). Is it
  regional? If yes, then make sure some sort of region string is in the name so you can have the US and EU
  version of it, and so on.


## Possible errors

* gcloud crashed (AttributeError): 'NoneType' object has no attribute 'SelfLink' => See
  [Stackoverflow](https://stackoverflow.com/questions/57031471/gcloud-crashed-attributeerror-nonetype-object-has-no-attribute-revisiontem)

* Some Org policies might prevent you from achieving your goal. For instance, a `constraints/compute.vmExternalIp`
  policy would prevent your GKE clusters to be set up with public IPs. Feel free to file a PR to fix this which is
  beyond the scope of this demo.

## Credits

* willisc7 for https://github.com/willisc7/next21-demo-golden-path and the
   inspiring `demo-startup.sh`. Yup, this also inspired this repo name.
* @danielmarzini for incredible help and guidance on GKE manifests.
* Alex Bielski for his support in getting a `Cloud Build` to work with multiple
  Skaffold modules, plus Skaffold *caching* and `kustomize` erudition.
* Yuki Furuyama for GCPDraw. Absolutely stunning. Making diagrams have never been so fun!
* ricc@: go/ricc-cd-canary-doc
