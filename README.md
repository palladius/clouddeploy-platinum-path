# 🐤 Canary Solutions with GCP Cloud Deploy

Quick links:

* [👨‍💻 Code](https://github.com/palladius/clouddeploy-platinum-path)
* [📰 Article on Medium](https://medium.com/@palladiusbonton/draft-canarying-on-gcp-with-cloud-deploy-91b3e4d0ee9a)
* [👣 Step by step 👣 guide](https://github.com/palladius/clouddeploy-platinum-path/blob/main/step-by-step-guide.md)
* [📹 Video on YouTube](https://youtu.be/0GfV5iMGG64)

This repo tries to demo a few applications (under `apps/`) and their path to
deployment via Google Cloud Platform's `Cloud Build` + `Cloud Deploy`.

I've tried to simplify the app and the `skaffold` part and concentrated on
automating the installation of Service Accounts, clusters, etc. all in
single scripts with a catchy name.

Note that EVERYTHING is automated except linking the external repo to Cloud
Build (this is currently possible in Alpha API which requires whitelisting).
All the shell scripts you see in the main directory have been
extensively tested, all the experimental code is under
[examples/](https://github.com/palladius/clouddeploy-platinum-path/tree/main/examples).

The only manual work you need to do are the 🧪Labs🧪 in the
[👣 Step by step 👣 guide](https://github.com/palladius/clouddeploy-platinum-path/blob/main/step-by-step-guide.md)
and I'm sure you're going to enjoy it.

**This is _NOT_ an officially supported Google product.**

## High-level architecture

In this diagram you can see the Build/Deploy part, while if you click you can see a high-resolution wider image
(complete with Load Balancers and stuff).

<!--
<img src="https://github.com/palladius/clouddeploy-platinum-path/blob/main/doc/Ricc%20Canary%20deployment%202022.png" alt="Architecture v1.1" align='right' />
-->
<a href="https://github.com/palladius/clouddeploy-platinum-path/blob/main/doc/bielski-nicer-architecture-diagram.png">
  <img src="https://github.com/palladius/clouddeploy-platinum-path/blob/main/doc/bielski-nicer-architecture-diagram-excerpt.png" alt="Architecture v1.4 excerpt" align='right' />
</a>


## Prerequisites

* A **Google Cloud Platform** account with billing enabled. Note that you can get started with a 300 USD credits
  [here](https://cloud.google.com/free) and you won't be charged after their depletion.
* A GitHub user (you can workaround to this).
* You can execute the scripts from your local machine, or from our awesome Google
  [Cloud Shell](https://cloud.google.com/shell) 🖥️ , which has all the dependencies you need.
* Some familiarity with CLI tools like `git`, `bash`, `kubectl`.

Now you're ready for the Step-by-step guide!

## 👣 Step by Step guide 👣

Click on the
[👣 Step by step guide 👣](https://github.com/palladius/clouddeploy-platinum-path/blob/main/step-by-step-guide.md)
to see how all scripts work and to find a few Labs to practice your *Cloud Deploy - fu 🥋*.

## The apps

The app part is really the NON-interesting part here. I tried to keep it as simple as
possible. *You* can complicate it as long as you have a Dockerfile or a Buildpack
to build it.

* `apps/app01/` This is a sample 🐍 *Python* app.
* `apps/app02/` This is a sample 💎 *Ruby* app (my favorite language).
* `apps/app03/` This is a sample 🧊 *Node.js* app (courtesy of Alex).

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


*For picky people*. Note that in the real world, the promotion from *DEV* to *STAGING* wouldn't probably happen as an
  effect of Unit Tests (rather Integration/Acceptance tests); however, in this demo I wanted as many releases out as
  possible with minimal manual intervention, so I did it this way.
  In a real scenario, a failed `make test` would prevent the DEV release
  altogether. Feel free to make the `Makefile` point to the code you need to execute in everystage and *voila*!


## Deploy philosophy

4 Deployment Targets have been created:

1. **dev**. Every successful commit lands here. Deploys to **dev** GKE cluster.
1. **staging**. Also deploys to **dev** GKE cluster.
1. **canary** *OR* **canary-production** (*depending on app*, see below). A release in this state will get a small
  amount of traffic (eg, 20%).
2. **production**. A release in this state will get *most* traffic. Deploys to **prod** GKE cluster.

Third stage (*canary**) depends on the application number:

* **App01**🐍 and **App02**💎 have **canary** as 3rd stage, which pushes to a **canary** GKE cluster.
  This has been done to demonstrate a complex, multi-cluster case.
* **App03**🧊 been configured differently with **canary-production** as 3rd stage , with Canary and Production stages
  *both* pushing to **prod** GKE cluster. This has been done to demonstrate a simpler use case.

**🤔 Confused**? Look at this graph:

<img src="https://github.com/palladius/clouddeploy-platinum-path/blob/main/doc/bifid tetra-pipeline.png?raw=true"
 alt="Four targets, 2 solutions depending on app" align='center' />


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

This is a very simple solution which was added last to show how simple it is to do Canary deployment just using
the power of Kubernetes and the ability of Cloud Build and Cloud Deploy to deploy different versions of the same app
in the same cluster.

Canarying is here achieved through pod-splitting, which means that I have for instance:

* 1 pods in **canary** with version **v1.43** (latest blazing version you're trying to test)
* 4 pods in **prod** with version **v1.42** (same old, same old)
* a service with "canary-or-prod" selector pointing to these 5 pods.

Therefore you have a ~20% probability to hit v1.42, and a ~80% probability of hitting the stable version. This could
not be true at all times, though: pods could die for a number of reason, altering the percentages; plus some pods could
be busier than others: what if the new canary release has increased the response latency by 100%?

Plus, how do you change from 80/20 to 81/19? Do you need 100 pods in general?

This solution is simple, cheap, but probably won't work in a sophisticated productive environment.

<img src="https://github.com/palladius/clouddeploy-platinum-path/blob/main/doc/solution4-from-slides.png?raw=true" alt="Solution 4 (simple)" align='center' />

### Complex solution: multi-cluster traffic-splitting canarying through Gateway API , envoy-backed ⚖️ XLB and 🪡 lot of weaving

<img src="https://github.com/palladius/clouddeploy-platinum-path/blob/main/doc/solution2-from-slides.png?raw=true" alt="Solution 4 (simple)" align='center' />

*(formerly known as: Solution 2)*


This solution solves the granularity issues of the Simple Solution, and it also allow you to have pods in multiple
clusters (which you don't have with simple Pod/Services artifacts). To achieve this, we use:

* **Gateway API** on the *kubernetes* side
* Forarding Rules + BackendServices on *GCP* side.
* Plus we use  **Zonal NEGs)** to connect the two. Network Endpoint Groups (NEGs) are a new, [sophisticated and flexible concept](https://cloud.google.com/load-balancing/docs/negs) in GCP:


<img src="https://github.com/palladius/clouddeploy-platinum-path/blob/main/doc/solution2-gcloud-part.png?raw=true" alt="Solution 2 gcloud Zoom" align='center' />

This is a bit harder to set up but is much more powerful.

## Solution

TODO(ricc): sol4 screenshot too.

This is what you'll see when you get Solution 2 to work:

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



## Credits

* willisc7 for https://github.com/willisc7/next21-demo-golden-path and the
   inspiring `demo-startup.sh`. Yup, this also inspired this repo name.
* @danielmarzini for incredible help and guidance on GKE manifests.
* [Alex Bielski](https://github.com/aablsk) for his support in getting a `Cloud Build` to work with multiple
  Skaffold modules, plus Skaffold *caching* and `kustomize` erudition.
* Yuki Furuyama for GCPDraw. Absolutely stunning. Making diagrams have never been so fun!
* ricc@: go/ricc-cd-canary-doc
* [cgrotz](https://github.com/cgrotz) for continuous help and feedback
* [Sander](https://github.com/sbbogdanc) and [Nate](https://github.com/nateaveryg) for sponsorship and priceless
  feedback.
