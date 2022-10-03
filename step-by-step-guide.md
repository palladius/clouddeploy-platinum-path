# 🐤 Step-by-step guide

This is a somewhat lengthier run through the scripts. Note that there are THREE Labs which are very useful to do.

- [🐤 Step-by-step guide](#-step-by-step-guide)
  - [First - a note on my scripts](#first---a-note-on-my-scripts)
  - [Scripts from 1 to 16](#scripts-from-1-to-16)
    - [`00-init.sh`](#00-initsh)
    - [`01-set-up-GKE-clusters.sh`](#01-set-up-gke-clusterssh)
    - [`02-setup-skaffold-cache-bucket.sh`](#02-setup-skaffold-cache-bucketsh)
    - [`03-configure-artifact-repo-and-docker.sh`](#03-configure-artifact-repo-and-dockersh)
    - [`04-status.sh`](#04-statussh)
    - [`05-IAM-enable-cloud-build.sh`](#05-iam-enable-cloud-buildsh)
    - [`06-WIP-automated-cloud-build-setup.sh`](#06-wip-automated-cloud-build-setupsh)
    - [`07-create-cloud-build-triggers.sh`](#07-create-cloud-build-triggerssh)
    - [`08-cloud-deploy-setup.sh`](#08-cloud-deploy-setupsh)
      - [🧪Lab🧪 Testing the solution: trigger Build apps](#lab-testing-the-solution-trigger-build-apps)
      - [🧪Lab🧪 Testing the solution: skaffold dev cycle [optional]](#lab-testing-the-solution-skaffold-dev-cycle-optional)
    - [`09-show-latest-successful-releases.sh`](#09-show-latest-successful-releasessh)
    - [`10-auto-promote-APP_XX-STAGE_YY-to-STAGE_ZZ.sh`](#10-auto-promote-app_xx-stage_yy-to-stage_zzsh)
      - [🧪Lab🧪 Testing the solution: promote to Canary and Prod](#lab-testing-the-solution-promote-to-canary-and-prod)
    - [11-14: *redacted*](#11-14-redacted)
    - [`15-solution2-xlb-GFE3-traffic-split.sh`](#15-solution2-xlb-gfe3-traffic-splitsh)
    - [`16-solution2-test-by-curling-N-times.sh`](#16-solution2-test-by-curling-n-timessh)
  - [Other great scripts](#other-great-scripts)

<!--
<small><i><a href='http://ecotrust-canada.github.io/markdown-toc/'>Table of contents generated with markdown-toc</a></i></small>
-->

## First - a note on my scripts

The root directory of my repo has a number of bash scripts which could discourage most of you. A few technical
and philosophical notes:

* Scripts must be run in alphabetical order from `00-XXX.sh` to `16-YYY.sh`.
* Every script is “transactional”, meaning if fails at first non-0 exit of a subcommand (this is achieved by `set -e`
  plus `bin/proceed_if_error_matches` for which I've been nominated for a Pulitzer). At the end of the script, a common
  routine will touch a file called `.executed_ok.04-status.sh.touch`. This will leave a breadcrumb trail which tells
  you where the script failed:

  <img src="https://github.com/palladius/clouddeploy-platinum-path/blob/main/doc/breadcrumbs-screenshot.png?raw=true" alt="Carlessian Breadcrumbs" align='center' />

* Everything in this is scripted except one point which requires manual intervention between step 6 and step 7, which
  is why I called the manual intervention 6.5 which I then moved at the beginning of the instructions (so now it looks
  more lie 0.065).

## Scripts from 1 to 16

### `00-init.sh`

**Initialization**. This scripts parses the ENV vars in `env.sh` and sets your `gcloud`, `skaffold` and GKE environment
  (`kubectl`) for success. If you leave this project, do something else with gcloud or GKE and come back to it tomorrow,
  its always safe to execute it once or even twice.

    🐧ricc@derek:~/clouddeploy-platinum-path$ ./00-init.sh

### `01-set-up-GKE-clusters.sh`

**Setting up GKE clusters**

  This script sets up 3 autopilot clusters:

* `cicd-noauto-canary`. It will contain canary workloads (pre-prod)
* `cicd-noauto-prod`. It will contain production workloads.
* `cicd-noauto-dev`. It will contain **everything else** (dev, staging, and my tests). It will also be the
  *default* cluster in case we make a mistake with `kubectl`.

Note:  Cluster Build can take several minutes to complete. You can check progress by viewing the
`Kubernetes Engine` -> `Kubernetes clusters` screen, or just have a **☕**.


### `02-setup-skaffold-cache-bucket.sh`

**Setup GCS + Skaffold Cache**.  This script creates a bucket which we'll use as Skaffold
   Cache ([more info](https://skaffold.dev/docs/references/cli/#skaffold-build)).
   This will make your Cloud Builds blazing ⚡ fast! Thanks AlexB/BrianDA for the tip!


### `03-configure-artifact-repo-and-docker.sh`

**Set up Artifact Repository and docker/k8s**. This just configures:
* `kubectl` to use the dev repo by default
* `skaffold` to use the $ARTIFACT_REPONAME.

5 seconds of your time, a couple of hours of mine to figure it out :) (*why is this not in the 00 script? Because
some things weren't necessarily up and running at that point*).

### `04-status.sh`
This is a script that I wrote to just check the status of the app and be invokable by my `Makefile`.
Depending on what I'm troubleshooting I’ll play around with:

```bash
# 📘 excerpt from File: `04-status.sh`
SHOW_VERBOSE_STUFF="false"
SHOW_GCLOUD_ENTITIES="false"
SHOW_DEVCONSOLE_LINKS="true"
SHOW_KUBERNETES_STUFF="true"
```

So you could call something like:

```bash
SHOW_VERBOSE_STUFF="false" SHOW_GCLOUD_ENTITIES="false" SHOW_DEVCONSOLE_LINKS="true" SHOW_KUBERNETES_STUFF="false" SHOW_SKAFFOLD_STUFF=false  ./04-status.sh
```

.. to only see gcloud entities and point your browser to them.

### `05-IAM-enable-cloud-build.sh`

Cloud Build needs to build images on your behalf, and possibly trigger events which push those artifacts to production.
To do so, it needs a Service Account to authenticate as, with proper powers. Take a moment to look at the rights that
have been granted in SUCCINCT_ROLE - most likely you will need to change them for your implementation if you use
different technologies:

**Note**: My “lazy” implementation makes Cloud Build a demiurgh, better implementations would create multiple
Service Accounts and get CB to impersonate as one or the other depending on the actions they need to perform - to
reduce the blast radius in case of an incident. In addition, if we were considering best practices we would not apply
all of the roles on project-level but instead on specific resources (e.g. `artifactregistry.writer` only on the
container repo, `iam.serviceAccountUser` only on the accounts that need to be impersonated, ..).

Example code for the last part:

```bash
# food for thought to harden your demo security (courtesy of Alex)
gcloud artifacts repositories add-iam-policy-binding $REPO_NAME \
  --role=roles/artifactregistry.repoAdmin \
  --member=serviceAccount:$YOUR_SERVICE_ACCOUNT_NAME@your-project.iam.gserviceaccount.com \
  --location=$REGION
```

### `06-WIP-automated-cloud-build-setup.sh`
You can safely skip this.
### `07-create-cloud-build-triggers.sh`

**Note** this script will fail if you didn't connect the repository as per
   instructions. This complicated script sets up Cloud Build for a number of apps, where I subsumed the "parameter" part
   in a Bash array (kudos for the courage). This configuration tells Cloud Build: Where to look for code, how to name
   the trigger, plus a number of less useful parameters.

```bash
# 📘 excerpt from File: `07-create-cloud-build-triggers.sh`
TEAMS[0]='T1py;app01;cloudbuild.yaml;apps/app01/;blue'
TEAMS[1]='T2rb;app02;cloudbuild.yaml;apps/app02/;green'
```



### `08-cloud-deploy-setup.sh`

**Create Cloud Deploy Infrastructure**. This sets up `clouddeploy.yaml` and creates:
two identical Delivery Pipelines for app01 and app02, plus a different pipeline for app03.

* For each pipeline, it creates four targets: **dev**, **staging**, **canary** (or **canary-prod** for app03) and **prod**.
* The slight complication here is that Cloud Deploy doesn’t support “hydration” of the YAML so we need to do it manually:
    * Look at clouddeploy.template.yaml
    * See how the bash script sed’s variables like `MY_PROJECT_ID`, `MY_REGION`, `_MY_VERSION_` to variables
      set up by script.



#### 🧪Lab🧪 Testing the solution: trigger Build apps

Now you can bump the version file of one or two apps and you should see the build making it into DEV and STAGING after
a couple of minutes, as in this screenshot:

<img src="https://github.com/palladius/clouddeploy-platinum-path/blob/main/doc/promo-dev-staging.png?raw=true"
 alt="Simple Promotion to Dev and Staging" align='center' />


```bash
source .env.sh # so you can use GITHUB_REPO_OWNER and other convenience vars.
git remote add $GITHUB_REPO_OWNER git@github.com:$GITHUB_REPO_OWNER/clouddeploy-platinum-path.git
echo 2.99test > ./apps/app01/VERSION # or whichever version it is plus one
echo 2.99test > ./apps/app02/VERSION # or whichever version it is plus one
git add ./apps/app01/VERSION
git add ./apps/app02/VERSION
git commit -m ‘bump version’
git push $GITHUB_REPO_OWNER main
```

#### 🧪Lab🧪 Testing the solution: skaffold dev cycle [optional]

**_Note_**: This was a very *Eureka* moment to me - although not strictly needed. This where you see all the power of
*skaffold*: you enter in an infinite dev loop where you change the code and its changes get built and pushed to GKE
as you code. Some code changes don’t even need a rebuild - but directly “scp” the changed file to prod via
[File Sync](https://skaffold.dev/docs/pipeline-stages/filesync/), my favorite skaffold feature.

Let’s now go into the first repo and try to leverage Skaffold for editing code and seeing its changes deployed to GKE (!).

```bash
$ cd apps/app01/
$ make dev
# I’m lazy and I assume you're lazy too. This command is the equivalent of:
# ricc@zurisack:🏡$ skaffold --default-repo “$SKAFFOLD_DEFAULT_REPO” dev
```

If the app compiles properly, this should issue a code push to Artifact Repository.

Plus, Skaffold should push your code to the k8s manifests as described in `skaffold.yaml` (in our cases this is
`./k8s/_base`, hence `kustomize`). **Note** If you use *autopilot* clusters, you might encounter quota issues, until the cluster
scales up to accommodate your new needs (which is why I removed autopilot by default).

Notice that you can leverage the FILE SYNC for your app to make sure only big change force a full rebuild. For instance,
my ruby apps take long to `Docker`ize, so to me it’s a killer feature that a small change to `main.rb` gets directly
pushed into the living container, while a change to `Gemfile` needs to force a full clean build.


###  `09-show-latest-successful-releases.sh`

This is a convenience script I wrote to tell me what was the last successful
release for an app.

```bash
$ ./09-show-latest-successful-releases.sh app01
$ ./09-show-latest-successful-releases.sh app02
# or for both:
$ make show-latest-succesful-releases
```

The culprit of the code is here:

```bash
gcloud deploy releases list --delivery-pipeline "$PIPELINE" \
  --filter renderState=SUCCEEDED \
  --format="value(name.split())" \
  --sort-by=~createTime --limit 1 |
    cut -d';' -f 8
```

### `10-auto-promote-APP_XX-STAGE_YY-to-STAGE_ZZ.sh`

This is another convenience script which i've created for YOU.

**Note**. Scripts from now on (10 and up) will fail miserably if you didn't successfully issue a Build Trigger via UI
or CLI as in the 08 lab. Make sure that Cloud Deploy has version deployed in Dev/Staging before proceeding. The easiest
way is to check [here](https://console.cloud.google.com/deploy/delivery-pipelines).

```bash
🐧$ ./10-auto-promote-APP_XX-STAGE_YY-to-STAGE_ZZ.sh <APP_ID> <TARGET_FROM> <TARGET_TO>
```

**Note** this script is just myself hitting my head around Cloud Deploy and doing CLI promotion. You can do it with a
simple click in the UI and maybe that’s what you should do the first 1-2 times.
When you are familiar with it, you can use this “swiss army knife script” to promote an app from a target to another.
I spent some time learning how to auto detect the latest release (hard) and then how to promote (easy).
The code is now in this script. For example, you can try to do first (it will pick up some reasonable defaults):

#### 🧪Lab🧪 Testing the solution: promote to Canary and Prod

The previous result (invoking the script with NO args) should be useless, as promote DEV to STAGE has already happened.
Try now this:

```bash
$ ./10-auto-promote-APP_XX-STAGE_YY-to-STAGE_ZZ.sh app01 staging canary
```

This should promote the release from second to third target, look:

<img src="https://github.com/palladius/clouddeploy-platinum-path/blob/main/doc/promote-to-canary.png?raw=true"
 alt="Promotion from Staging to Canary (CLI)" align='center' />

.. and it works!

So this script should be your swiss army knife for promoting the latest release for appXX from any target to any target (I haven’t tested bad directions, like 2 to 4 or 3 to 2: you should only be doing from N to N+1).

For the second promotion, we will use the **UI** as it’s beautiful:
* Open the browser at: https://console.cloud.google.com/deploy/delivery-pipelines
* Click on *App01*. You should see the first 3 stages with a green color, while no rollouts associated to prod.
* Click **Promote** here:

<img src="https://github.com/palladius/clouddeploy-platinum-path/blob/main/doc/promote-canary-prod-ui.png?raw=true"
 alt="Promotion from Canary to Prod (UI)" align='center' />

 * Fill in a rollout description (eg "I follow riccardo README suggestions"), so you can laugh at yourself when it
   breaks in the future :)

* I really love the UI since it brings a lot of contextual data:
    * First a rollout comment, useful in the future
    * Second, a manifest diff so you can see what you’re really changing. This is NOT available for the very first
      rollout, but comes interesting from the second on. It links error to right contextual logs. So every error is
      one click away to investigate the issue.

###  11-14: *redacted*

Steps 11-14 have been redacted. If curiouis, check under `examples/`

###  `15-solution2-xlb-GFE3-traffic-split.sh`

**Set up traffic split (solution 2!)**

This is how NEGs will look for your two endpoints. The "healthy" column will help you torubleshoot it all.

<img src="https://github.com/palladius/clouddeploy-platinum-path/blob/main/doc/app02-sol2-svc-canaryprod-neg-view.png?raw=true" alt="Solution 2 NEG view on GCP GCLB page" align='center' />


### `16-solution2-test-by-curling-N-times.sh`

Once you set up the traffic splitting "infrastructure", this script
will simply do a `kubectl down` and `kubectl up` and test the setup.

*Q. Why is this split into TWO scripts?* Initially the setuip part took a long time, while the kubernetes apply took one
second. Hence I split this in two parts to be able to edit the k8s Manifests and test the result with a click. After
the code has stabilized, this still feels like a decent split, in case you want to edit manifests and see what changes
in "prod".

## Other great scripts

I've disseminated `bin/` with scripts that I utilized for testing my solutions. You might find them useful (and send me
a PR to fix the errors ). Some examples:

    🐧ricc@derek:$ bin/curl-them-all

<img src="https://github.com/palladius/clouddeploy-platinum-path/blob/main/doc/curl-them-all-screenshot.png?raw=true" alt="curl-them-all script example" align='center' />

