# clouddeploy-platinum-path

Self: https://github.com/palladius/clouddeploy-platinum-path

This repo tries to demo a few applications (under `apps/`) and it's path to
deployment via Google Cloud Platform's `Cloud Build` + `Cloud Deploy`.
Since a lot of setup is needed, I took inspiration from `willisc7` Golde Path
repo (see below).

I've tried to simplify the app and the `skaffold` part and concentrated on
automating the installation of Service Accounts, clusters, etc. all in
single scripts with a catchy name.

Note that EVERYTHING is automated except linking the external repo to Cloud
Build (talked to the PM, this is currently possible in alpha API and it's
among my TODOs).

Doc: go/ricc-cd-canary-doc

**This is not an officially supported Google product.**

## High-level architecture

<img src="https://github.com/palladius/clouddeploy-platinum-path/blob/main/doc/Ricc%20Canary%20deployment%202022.png" alt="Architecture v1.1" align='right' />


## Install

* Create a project on GCP and assign billing to it. There gonna be clusterz so quota might hit you :/
* `cp .env.sh.dist .env.sh`
* Edit away with your personal project ids.
* `sh 00-init.sh` and so on.. for all steps.
* Do steps 1,2,3,4,5,6 automatically: `make first-half`
* Follow manual instructions for 6.5 below.
* Do steps 7,8,9,..,16 automatically - `make second-half`

You should be good to go!

For more shenaningans you might need to install `lolcat` (`gem install lolcat`) as
it colors my life and most likely yours too. Some scripts in here can all be found
in my [Swiss-Army Knife repo](https://github.com/palladius/sakura/), but the ones needed
for this are all uinder `bin/`.

### Manual part (step 6.5)

I'm working on it in a Google Doc ATM (go/ricc-cd-canary-doc). When finished
I'll migrate text and images here. Meanwhile, you can follow the official docs here:

* To connect your github repo: https://cloud.google.com/build/docs/automating-builds/github/build-repos-from-github

## The apps

The app part is really the NON-interesting part here. I tried to keep it as simple as
possible. You can complicate it as long as you have a Dockerfile or a Buildpack
to build it.

* `apps/app01/` This is a sample 🐍 *Python* app.
* `apps/app02/` This is a sample 💎 *Ruby* app.
* `apps/app03/` This is a sample 🧊 *Node.js* app.

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
```

## Build philosophy

* Every commit to `main` will trigger a Cloud Build, provided code is in some `apps/appXX/` . In particular, any change to the code to app01 will trigger a build in the APP01 pipeline, and so on. **Yes**, it's that beautiful.

* Promotion DEV -> STAGING. This is a second BUILD which also executes `make test` in the
`app/MYAPP` folder.

* *For picky people*. Note that in the real world, the promotion from DEV to STAGING wouldn't happen after Unit Tests (rather integration tests), but for this demo I wanted as many releases out as possible with minimal manual intervention, so I did it this way. In a real scenario, a failed `make test` would prevent the DEV release altogether.

## Deploy philosophy

4 targets have been created.

* **App01** and **App02** have 4 stages, with canary and production making it to two separated GKE cluster with the same name. This has been done to demonstrate a complex, multi-cluster case.
* **App03** has been configured differently, with Canary and Production stages *both* pushing to prod GKe cluster. This has been done to demonstrate a simpler use case.

## Canary solutions

Historically, 3 solutions have been provided. History is important since it plays a role
into script numbering ;) so here we are. A fourth solution has been added in July 22.

* Solution0: ILB + TrafficSplitting. Doesnt have public IP. Initial code: https://github.com/palladius/clouddeploy-platinum-path/pull/3/files (script 11)
* Solution1: Global XLB + Gateway API + Pod splitting.
* Solution2: Envoy-based new XLB
* Solution3: *symlink* to solution0
* **Soultion4** (**simple solution**): single-cluster pod-splitting for `app03`.

More info on historical code under `k8s/amarcord/` (Romagnolo Italian for *I remember*, plus [memorable movie by Federico Fellini](https://en.wikipedia.org/wiki/Amarcord)).

*(XLB: eXternal Load Balancer)*

### Simple solution: single-cluster pod-splitting thru k8s service

*(formerly known as: Solution 4)*

TODO(ricc): images

### Complex solution: multi-cluster traffic-splitting canarying through Gateway API , envoy-backed XLB and 🪡 lot of weaving

*(formerly known as: Solution 2)*

This is what you'll see when you get this to work:

<img src="https://github.com/palladius/clouddeploy-platinum-path/blob/main/doc/solution2 app01 python sample.png" alt="Solution 2 exmaple" align='center' />


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


## Credits

* willisc7 for https://github.com/willisc7/next21-demo-golden-path and the
   inspiring `demo-startup.sh`. Yup, this also inspired this repo name.
* @danielmarzini for incredible help and guidance on GKE manifests.
* Alex Bielski for his support in getting a `Cloud Build` to work with multiple
  Skaffold modules, plus Skaffold *caching* and `kustomize` erudition.
* Yuki Furuyama for GCPDraw. Absolutely stunning. Making diagrams have never been so fun!
