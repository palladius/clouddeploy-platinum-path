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
it colors my life and most likely yours too. If you insist on a gray life, just
rename lolcat to cat :) Other scripts can all be found in my Swiss-Army Knife repo:
https://github.com/palladius/sakura/

### Manual part (step 6.5)

I'm working on it in a Google Doc ATM (go/ricc-cd-canary-doc). When finished
I'll migrate text and images here.

## The apps

The app part is really the NON-interesting part here. I tried to keep it as simple as
possible. You can complicate it as long as you have a Dockerfile or a Buildpack
to build it.

* `apps/app01/` This is a sample Python app.
* `apps/app02/` This is a sample Ruby app.

They both expose a single Web page (`/`) with a lot of debug useful information, usually
surfaced by proper ENV vars. They also expose a second convenience endpoint (`/statusz`)
with a one-liner description (used by scripts), such as:

```
app=app01 version=2.23 target=prod emoji=🐍
app=app01 version=2.22 target=canary emoji=🐍
[..]
app=app02 version=2.0.6 target=prod emoji=💎
app=app02 version=2.0.7 target=canary emoji=💎
```

## Build philosophy

* Every commit to TRUNK will trigger a Cloud Build, no matter what. In particular, any
change to the code to app01 will trigger a build in the APP01 pipeline, and same for App02.
Yes, it's that beautiful.
* Promotion DEV -> STAGING. This is a second BUILD which also executes `make test` in the
`app/MYAPP` folder.

## Deploy philosophy

4 targets have been created, as you can see above.

## Canary solutions

Historically, 3 solutions have been provided. History is important since it plays a role
into script numbering ;)

* Solution0: ILB + TrafficSplitting. Doesnt have public IP. Initial code: https://github.com/palladius/clouddeploy-platinum-path/pull/3/files (script 11)
* Solution1: Global XLB + Gateway API + Pod splitting.
* Solution2: Envoy-based new XLB

More info on historical code under `k8s/amarcord/` (Romagnolo Italian for *I remember*)

*(XLB: eXternal Load Balancer)*

### Solution 2

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
