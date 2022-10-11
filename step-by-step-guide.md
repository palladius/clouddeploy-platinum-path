# 👣 Step by step 👣 guide


<!--
<small><i><a href='http://ecotrust-canada.github.io/markdown-toc/'>Table of contents generated with markdown-toc</a></i></small>
Riccardo instructions:
1. paste this page into http://ecotrust-canada.github.io/markdown-toc/
2. remove the above H1. First line should be sth like: * [Setting things up](#setting-things-up)
3. remove the markdown toc self generate part its already above and we thank these canadian folks for help!

BUGS
* I noticed the links are not clickable in general. I'm trying again removing EMOJIs and `backquotes`.
* Bug seems to be fixed if you do NOT remove the first line, but you < ! - - comment it - - > instead.
-->
<!--
- [👣 Step by step 👣 guide](#-step-by-step--guide)
-->
- [👣 Step by step 👣 guide](#-step-by-step--guide)
  - [Setting things up](#setting-things-up)
  - [Bash Scripts (from 1 to 16)](#bash-scripts-from-1-to-16)
    - [A note on the *bash* scripts](#a-note-on-the-bash-scripts)
    - [`00-init.sh` (🕰)](#00-initsh-)
    - [`01-set-up-GKE-clusters.sh` (🕰)](#01-set-up-gke-clusterssh-)
    - [`02-setup-skaffold-cache-bucket.sh`](#02-setup-skaffold-cache-bucketsh)
    - [`03-configure-artifact-repo-and-docker.sh`](#03-configure-artifact-repo-and-dockersh)
    - [`04-status.sh`](#04-statussh)
    - [`05-IAM-enable-cloud-build.sh`](#05-iam-enable-cloud-buildsh)
    - [`06-WIP-automated-cloud-build-setup.sh`](#06-wip-automated-cloud-build-setupsh)
    - [`07-create-cloud-build-triggers.sh`](#07-create-cloud-build-triggerssh)
    - [`08-cloud-deploy-setup.sh`](#08-cloud-deploy-setupsh)
      - [Lab 1 🧪 Trigger Build apps](#lab-1--trigger-build-apps)
      - [Lab 2 🧪 Testing skaffold dev cycle [optional]](#lab-2--testing-skaffold-dev-cycle-optional)
    - [`09-show-latest-successful-releases.sh`](#09-show-latest-successful-releasessh)
    - [`10-auto-promote-APP_XX-STAGE_YY-to-STAGE_ZZ.sh`](#10-auto-promote-app_xx-stage_yy-to-stage_zzsh)
      - [Lab 3 🧪 Promote to Canary and Prod](#lab-3--promote-to-canary-and-prod)
      - [Lab 4 🧪 Observe Simple Solution for app03](#lab-4--observe-simple-solution-for-app03)
    - [11-14: *redacted*](#11-14-redacted)
    - [`15-solution2-xlb-GFE3-traffic-split.sh` (🕰)](#15-solution2-xlb-gfe3-traffic-splitsh-)
    - [`16-solution2-test-by-curling-N-times.sh`](#16-solution2-test-by-curling-n-timessh)
      - [Lab 5 🧪 Test solution2](#lab-5--test-solution2)
  - [Other great scripts](#other-great-scripts)
    - [bin/curl-them-all](#bincurl-them-all)
    - [bin/kubectl-$STAGEZ](#binkubectl-stagez)
    - [bin/troubleshoot-solutionN](#bintroubleshoot-solutionn)
    - [bin/{rcg, lolcat, proceed_if_error_matches}](#binrcg-lolcat-proceed_if_error_matches)
  - [Possible Errors](#possible-errors)
    - [E001 Quota Issues](#e001-quota-issues)
    - [E002 source: .env.sh: file not found](#e002-source-envsh-file-not-found)
    - [E003 Some dependencies missing](#e003-some-dependencies-missing)
    - [E004 MatchExpressions LabelSelectorRequirement field is immutable](#e004-matchexpressions-labelselectorrequirement-field-is-immutable)
    - [E005 missing gcloud config](#e005-missing-gcloud-config)
    - [E006 Miscellaneous errors](#e006-miscellaneous-errors)
    - [E007 Code is still broken!](#e007-code-is-still-broken)
  - [Additional readings](#additional-readings)




## Setting things up

All scripts in the root directory are named in numerical order and describe the outcome they’re intended to achieve.

Before executing any bash script, they all source a `.env.sh` script which you’re supposed to create (from the
`.env.sh.dist` (file) and maintain somewhere else (I personally created and use
[git-privatize](https://github.com/palladius/sakura/blob/master/bin/git-privatize)
and symlink it from/to another private repo).

1. Choose your environment.
    * You can use Google [Cloud Shell IDE](https://ide.cloud.google.com) 🖥️ (leveraging the awesome integrated editor).
      This code has been fully tested there. Note Cloud Shell is an ephemeral machine. If you come back from lunch and
      the machine is lost, you can always reload it. When you do, some ENV variables are lost so it's **important** for
      you to re-run the `00-init.sh` every time you *come back from lunch*.
    * **Linux** machine where you’ve installed `gcloud`.
    * **Max OSX** with bash v5 or more (to support hashes). To do so, just try `brew install bash` and make sure to use
      the new BASH path ~(you might have to explicitly call the scripts with `bash SCRIPTNAME.sh`).

2. [Fork](https://github.com/palladius/clouddeploy-platinum-path/fork) the code repo:
    * Go to https://github.com/palladius/clouddeploy-platinum-path/
    * Click “**Fork”** to fork the code under your username.

    <img src="https://github.com/palladius/clouddeploy-platinum-path/blob/main/doc/github-fork.png?raw=true" alt="GitHub Fork" align='center' />

   * New URL will look like this: https://github.com/daenerys/clouddeploy-platinum-path [with your username].
     You’ll need this username in a minute.
       * **__Note:__** that if you don’t have a github account (and you don’t want to create one), you can just fork my repo in your
     GCR - more instructions later in the step *07* below.
   * To connect your github repo, extensive instructions are [here](https://cloud.google.com/build/docs/automating-builds/github/build-repos-from-github). However, following the next steps should suffice.
   * Open **Cloud Developer Console** > **Cloud Build** and click on **ENABLE API**
       * **__Note:__** this screen may not appear if the API is already enabled
   * Open **Cloud Developer Console** > **Cloud Build** > **Triggers**: https://console.cloud.google.com/cloud-build/triggers
   * Click on **Connect repository** button (bottom of page):

    <img src="https://github.com/palladius/clouddeploy-platinum-path/blob/main/doc/cloudbuild-connect-repo.png?raw=true" alt="Connect Repository on Cloud Build" align='center' />

    * “Select Source” > “**GitHub (Cloud Build GitHub App)**” and click “continue”. Follow the authentication flow, if
      needed. (On github side, you can find/edit the Cloud Build integration
      [here](https://github.com/settings/installations/).)

    * Type “Create a sample trigger“ because why not. We'll delete it later.

3.  Now back to your client shell (Linux Bash, Mac bash, or Cloud Shell). Cloud Shell icon should be a 🖥️ terminal
      icon on top right of your Google Cloud Console. Clone the repository you just forked:

  ```bash
  riccardo@cloudshell:~$ git clone https://github.com/palladius-uat/clouddeploy-platinum-path
  riccardo@cloudshell:~$ cd clouddeploy-platinum-path
  ```

1. *[Totally optional]* Install a colorizing gem. If you won’t do it, there’s a `lolcat` fake wrapper in `bin/` (added to
   path in init script). But trust me, it’s worth it (unless you have no Ruby installed).

    `gem install lolcat`


1. Copy the env template to a new file that we’ll modify

    `cp .env.sh.dist .env.sh`

1. Open `.env.sh` and substitute the proper values for any variable that has # changeme next to it.
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


Tip (*optional*): If you want to persist your personal `.env.sh`, consider using
[my script](https://github.com/palladius/sakura/blob/master/bin/git-privatize) `git-privatize`. If  you
find a better way, please tell me - as I’ve looked for the past 5 years and this is the best I came up with.

## Bash Scripts (from 1 to 16)

Originally there were 16 scripts, then with time I removed them, renamed them, moved them.

Whenever I wasn't able to fully support some code but I thoguht that code would be useful to some of you, I moved it
under `examples/`; so think of examples like a 🪦 cemetery, or a
*Derek Zoolander's Center For Scripts Who Can't Be Read Good*.

### A note on the *bash* scripts

The root directory of my repo has a number of bash scripts which could discourage most of you. A few technical
and philosophical notes:

* Scripts must be run in alphabetical order from `00-XXX.sh` to `16-YYY.sh`.
* Every script is “transactional”, meaning if fails at first non-0 exit of a subcommand (this is achieved by `set -e`
  plus `bin/proceed_if_error_matches` for which I've been nominated for a Pulitzer). At the end of the script, a common
  routine will touch a file called `.executed_ok.04-status.sh.touch`. This will leave a breadcrumb trail which tells
  you where the script failed. For more info see  [E003 Some dependencies missing](#e003-some-dependencies-missing).
* Everything in this is scripted except one point which requires manual intervention, which is the cloning of the repo.
  This step was originally step 6.5 which I then moved at the beginning of the instructions (so now it looks
  more lie 0.065). So if your script 7 fails, you know where to look.

### `00-init.sh` (🕰)

**Initialization**. This scripts parses the ENV vars in `env.sh` and sets your `gcloud`, `skaffold` and GKE environment
  (`kubectl`) for success. If you leave this project, do something else with gcloud or GKE and come back to it tomorrow,
  its always safe to execute it once or even twice.

    🐧ricc@derek:~/clouddeploy-platinum-path$ ./00-init.sh

Notes:

* The first time you execute, depending on your execution environment, you might receive a request to authenticate via
  a mouse click, and/or a suggestion to call `gcloud auth login`. Make sure to follow the flow until your local
  environment is able to authenticate as you.
* If you have been interrupted, make sure to execute the script again (wghen in doubt, follow the *breadcrumbs*).
* First execution might take a while (🕰)

### `01-set-up-GKE-clusters.sh` (🕰)

**Setting up GKE clusters**. This script sets up 3 autopilot clusters:

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
[...]
```

* If you created a sample trigger, this is the time to delete or disable it (click on the 3 vertical dots and click
  '*disable*').

### `08-cloud-deploy-setup.sh`

**Create Cloud Deploy Infrastructure**. This sets up `clouddeploy.yaml` and creates:
two identical Delivery Pipelines for app01 and app02, plus a different pipeline for app03.

* For each pipeline, it creates four targets: **dev**, **staging**, **canary** (or **canary-prod** for app03)
  and **prod**.
* The slight complication here is that Cloud Deploy doesn’t support “hydration” of the YAML so we need to do it
  manually:
    * Look at `clouddeploy.template.yaml`
    * See how the bash script `sed`s variables like `MY_PROJECT_ID`, `MY_REGION`, `_MY_VERSION_` to variables
      set up by script.


#### Lab 1 🧪 Trigger Build apps

Now you can bump the version file of one or two apps and you should see the build making it into DEV and STAGING after
a couple of minutes, as in this screenshot:

<img src="https://github.com/palladius/clouddeploy-platinum-path/blob/main/doc/promo-dev-staging.png?raw=true"
 alt="Simple Promotion to Dev and Staging" align='center' />

**Pre-requisites:**
* First `git commit` might require setting your name and email, no biggie. Use the following:
    ```
    git config --global user.name "FIRST_NAME LAST_NAME"
    git config --global user.email "GITHUB_EMAIL@example.com"
    ```
* Your first `git push` might require setting up a proper authentication mode. Personally, my favorite is this:
     * `$ cd ~/.ssh`
     * `ssh-keygen` # creates a key
     * `cat id_rsa.pub` # => and CTRL-C content of neewly created key.
     * Open Github > Settings > "[Ssh keys](https://github.com/settings/keys)" > "[New SSH key](https://github.com/settings/ssh/new)"
         * Title: "My cloud shell RSA key for Riccardo Platinum Project"
         * Key: paste the content of the key.

To start, try something like this:

```bash
source .env.sh # so you can use GITHUB_REPO_OWNER and other convenience vars.
git remote add $GITHUB_REPO_OWNER git@github.com:$GITHUB_REPO_OWNER/clouddeploy-platinum-path.git
echo 2.99test > ./apps/app01/VERSION # or whichever version it is plus one
echo 2.99test > ./apps/app02/VERSION # or whichever version it is plus one
git add ./apps/app01/VERSION
git add ./apps/app02/VERSION
git commit -m 'bump PRODUCTION version' # this might require you first do some global git config'ing..
git push $GITHUB_REPO_OWNER main
```

This should trigger `app01` and `app02` trigger, but not app03:

<img src="https://github.com/palladius/clouddeploy-platinum-path/blob/main/doc/lab1-cloudbuild-app12.png?raw=true"
 alt="Lab1: Cloud Build" align='center' />

* Now change the `./apps/app03/VERSION`, commit and push to see that a new build trigger with app03 is actually
  executed. Don't you love Cloud Build? Thanks to the file GLOB selector, it only builds the changed directories!
* **IMPORTANT**. Repeat exactly the same process again, since we need TWO versions "in the cloud" ☁️.

```bash
echo 2.100 > ./apps/app01/VERSION
echo 2.100 > ./apps/app02/VERSION
echo 2.100 > ./apps/app03/VERSION
git commit -a -m 'trying a new super duper experimental feature'
git push $GITHUB_REPO_OWNER main
```

**Note:** check the apps on your GKE Services dashboard. You should see the following applications:
  * `app01-kupython`
  * `app02-kuruby`
  * `app03-kunode` (yup, plenty of fantasy here. `ku` stands for Kustomize).

#### Lab 2 🧪 Testing skaffold dev cycle [optional]

**_Note_**: This was a very *Eureka* moment to me - although not strictly needed. This where you see all the power of
*skaffold*: you enter in an infinite dev loop where you change the code and its changes get built and pushed to GKE
as you code. Some code changes don’t even need a rebuild - but directly “scp” the changed file to prod via
[File Sync](https://skaffold.dev/docs/pipeline-stages/filesync/), my favorite skaffold feature.

Let’s now go into the first repo and try to leverage Skaffold for editing code and seeing its changes deployed to GKE (!).

1. Start skaffold
    ```bash
    $ cd apps/app01/
    $ make dev
    # I’m lazy and I assume you're lazy too. This command is the equivalent of:
    # ricc@zurisack:🏡$ skaffold --default-repo “$SKAFFOLD_DEFAULT_REPO” dev
    ```
1. Edit web.py and replace `Hello world from Skaffold in python!` with `Hello world!`
    * **Note:** On 🐚 Cloud Shell, you can achieve this by clicking `📝 Open Editor` button. You can always come back with `Open Terminal` button when you need your 🐚 shell back.
1. Switch back to the shell and you'll see the app is being rebuilt

If the app compiles properly, this should issue a code push to Artifact Repository.

Plus, Skaffold should push your code to the k8s manifests as described in `skaffold.yaml` (in our cases this is
`./k8s/_base`, hence `kustomize`). **Note** If you use *autopilot* clusters, you might encounter quota issues, until the cluster
scales up to accommodate your new needs (which is why I removed autopilot by default).

Notice that you can leverage the `FILESYNC` for your app to make sure only big change force a full rebuild. For instance,
for `app02`, my ruby apps take long to `Docker`ize, so to me it’s a killer feature that a small change to `main.rb` gets
directly pushed into the living container, while a change to `Gemfile` needs to force a full clean build. In other words,
FileSync allows you to re-build the minimum necessary at every change in the dev cycle, a dream for developers!

* Now do another `git commit`, so you have TWO versions for app01.

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
PIPELINE=app01
gcloud deploy releases list --delivery-pipeline "$PIPELINE" \
  --filter renderState=SUCCEEDED \
  --format="value(name.split())" \
  --sort-by=~createTime --limit 1 |
    cut -d';' -f 8
```

You can try this:

* Now try to invoke it for `app01` or whatever app you've changed and observe the LATEST_SUCCESSFUL_RELEASE to be output
  from the terminal (`./09-show-latest-successful-releases.sh app01`). You might want to note the code to achieve that.
* Now find the exact same information delving in the "Cloud Deploy" UI > `app01`
  "[Delivery Pipeline](https://console.cloud.google.com/deploy/delivery-pipelines/us-central1/app01)"
  > "Rollouts" tab.

### `10-auto-promote-APP_XX-STAGE_YY-to-STAGE_ZZ.sh`

This is another convenience script which i've created for 🎩 *YOU*.

**Note**. Scripts from now on (10 and up) will fail miserably if you didn't successfully issue a Build Trigger via UI
or CLI as in the 08 lab. Make sure that Cloud Deploy has version deployed in Dev/Staging before proceeding. The easiest
way is to check [here](https://console.cloud.google.com/deploy/delivery-pipelines).

```bash
🐧$ ./10-auto-promote-APP_XX-STAGE_YY-to-STAGE_ZZ.sh <APP_ID> <TARGET_FROM> <TARGET_TO>
```

**Note** this script is just myself hitting my head around Cloud Deploy and doing CLI promotion. You can do it with a
simple click in the UI and maybe that’s what you should do the first 1-2 times.

When you are familiar with it, you can use this “swiss army knife script” to promote an app from a target to another.
I spent some time learning how to auto detect the latest release (hard, so I put in the 09 script) and then how to
promote (easy).
The code is now in this script. For example, you can try to do first (it will pick up some reasonable defaults):

#### Lab 3 🧪 Promote to Canary and Prod

We will perform two actions, one with command line and one from UI. You get to decide which you like the most.

**1. Staging to Canary promotion (via CLI)**

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

**2. Canary to Prod promotion via UI**

For the second promotion, we will use the **UI** as it’s simple and beautiful:

* Open the browser at: https://console.cloud.google.com/deploy/delivery-pipelines
* Click on *App01*. You should see the first 3 stages with a green color, while no rollouts associated to prod.
* Click **Promote** here:

<img src="https://github.com/palladius/clouddeploy-platinum-path/blob/main/doc/promote-canary-prod-ui.png?raw=true"
 alt="Promotion from Canary to Prod (UI)" align='center' />

* Fill in a rollout description (eg "I follow Riccardo README suggestions"), so you can laugh at yourself when it
   breaks in the future :)

* Click `PROMOTE`

* I really love the UI since it brings a lot of contextual data:
    * First a rollout comment, useful in the future
    * Second, a manifest `diff` so you can see what you’re really changing. This is NOT available for the very first
      rollout (for obvious reasons), but becomes interesting from the second on. It links error to right contextual
      logs. So every error is one click away to investigate the issue. The Google way 🦚 :)


#### Lab 4 🧪 Observe Simple Solution for app03

Now that you got confident committing changing for apps and observe them flow to Cloud Deploy, plus promoting version
to your favorite target, you can get your first satisfaction. **Simple Solution** will start working for `app03` as soon as you
have two (possibly distinct) versions in Canary and Prod. If the versions are the same, you'll have a hard time noticing
a difference but you could inject change in the code :) The simplest way, however is to have the latest version in
canary and the pentultimate version in prod.

Instructions:

* Use **Lab 1** instructions to change version in `app03` twice (eg `v2.99` and `2.100`) and deploy both.
* Promote 2.99 to prod/canary, then 2.100 to canary using instyructions in script **10**.
* go to GKE > [Services](https://console.cloud.google.com/kubernetes/discovery?e=-13802955&project=cicd-platinum-test008&pageState=(%22savedViews%22:(%22i%22:%226fade9ce3eaf42d2ac125fc083079c14%22,%22c%22:%5B%5D,%22n%22:%5B%5D))) page and observe the Prod and Canary version public IPs.
* You can also test the solution with this amazing script: `bin/troubleshoot-solution4`. I know, right?

###  11-14: *redacted*

Steps 11-14 have been redacted. If curious, check under `examples/`

### `15-solution2-xlb-GFE3-traffic-split.sh` (🕰)

**Set up traffic split (solution 2!)**. This quite complex script will make intensive use of `gcloud` and `kubectl` to
set up the Traffic Splitting. If this code is confusing to you, you can look at the instructions I used from my mentor
Daniel to set it up, under
[`k8s/amarcord/original-solution2-dmarzi/`](https://github.com/palladius/clouddeploy-platinum-path/blob/main/k8s/amarcord/original-solution2-dmarzi/readme.md)
. While the 15 script sets up just the `gcloud` part (🕰), the 16 scripts runs the needed `kubectl apply` (fast).

This is how [NEGs](https://cloud.google.com/load-balancing/docs/negs) will look for your two endpoints.
The "healthy" column will help you troubleshoot it all.

<img src="https://github.com/palladius/clouddeploy-platinum-path/blob/main/doc/app02-sol2-svc-canaryprod-neg-view.png?raw=true" alt="Solution 2 NEG view on GCP GCLB page" align='center' />

**Notes**.

* This script only works for app01 and appp02. app03 is designed to work only for the Simple Solution and is already
  working without any script.
* You should launch this script only if you app01 or app02.
* **Important** The first time you execute it, you need to wait ~one hour (🕰) for
Gateway APIs to be 'installed' and fully functional in your GKE clusters.

### `16-solution2-test-by-curling-N-times.sh`

Once you set up the traffic splitting "infrastructure", this script
will simply do a `kubectl down` and `kubectl up` and test the setup.

*Q. Why is this split into TWO scripts?* Initially the setuip part took a long time, while the kubernetes apply took one
second. Hence I split this in two parts to be able to edit the k8s Manifests and test the result with a click. After
the code has stabilized, this still feels like a decent split, in case you want to edit manifests and see what changes
in "prod".

Notes:

* If the solution 2 doesn't work, make sure that 60-90 minutes have passed from the first invocation of script 15. You
  can use my *Grimms*-ian breadcrumbs:

```bash
$ 🐼 make breadcrumb-navigation  | grep 15-solution2
-rw-r--r-- 1 ricc primarygroup 7 Sep  6 13:29 .executed_ok.15-solution2-xlb-GFE3-traffic-split.sh.touch
```

#### Lab 5 🧪 Test solution2

Now if everythign works fine, you should be able to observe the proper traffic split by sending numerous curls.

the easiest is to use my script:

```bash
ricc@derek:~/clouddeploy-platinum-path$ bin/solution2-simple-curl
[DEBUG] IP_FWDRULE[app01]: 35.244.160.220
app=app01 version=2.25croatia target=prod emoji=🐍
app=app01 version=2.25croatia target=canary emoji=🐍
app=app01 version=2.25croatia target=canary emoji=🐍
app=app01 version=2.25croatia target=prod emoji=🐍
app=app01 version=2.25croatia target=prod emoji=🐍
app=app01 version=2.25croatia target=prod emoji=🐍
app=app01 version=2.25croatia target=prod emoji=🐍
app=app01 version=2.25croatia target=prod emoji=🐍
app=app01 version=2.25croatia target=prod emoji=🐍
app=app01 version=2.25croatia target=prod emoji=🐍
app=app01 version=2.25croatia target=prod emoji=🐍
app=app01 version=2.25croatia target=canary emoji=🐍
[DEBUG] IP_FWDRULE[app02]: 34.111.249.225
app=app02 version=2.0.7 target=canary emoji=💎
app=app02 version=2.0.7 target=canary emoji=💎
app=app02 emoji=💎 target=prod version=2.0.8
app=app02 emoji=💎 target=prod version=2.0.8
app=app02 emoji=💎 target=prod version=2.0.8
app=app02 version=2.0.7 target=canary emoji=💎
app=app02 emoji=💎 target=prod version=2.0.8
app=app02 version=2.0.7 target=canary emoji=💎
app=app02 emoji=💎 target=prod version=2.0.8
app=app02 emoji=💎 target=prod version=2.0.8
app=app02 emoji=💎 target=prod version=2.0.8
app=app02 emoji=💎 target=prod version=2.0.8
```

You should observe a majority of PROD pods in app01 and app02.

If you observe empty output, check the Cloud Deploy Pipeline page for app01 and app02, and make sure they have a proper
version in both CANARY and PROD targets. If you don't, go back to labs 1-4 and ensure you loaded enough versions in both
apps (tip: most scripts defaulty to `app01` in `ARGV[1]` so make sure you give `app02` ❤️ some love too).

For exmaple:

<img src="https://github.com/palladius/clouddeploy-platinum-path/blob/main/doc/bad-pipeline-missing-prod.png?raw=true" alt="This Delivery Pipeline clearly misses a PROD target" align='center' />

Here you clearly missed deploying to prod, so you can fix by promoting STAGING to PROD. However, this would be ugly
since you'd have the same version but it would be a first good step. After this you might want to:

* EDIT `app/app01/VERSION`  to 2.100
* git commit
* Wait until Cloud Build does its part and dev/staging get the 2.100.
* promote v2.100 from STAG to CANARY.
* relaunch the `bin/solution2-simple-curl`
* If this still fails, chances are Gateway API isnt ready yet. Try again in 90 minutes.
* If that stil fails, please open an issue on my repo with the output.

**Note**. If you only see app01 and **not app02** on the GKE page 9as in figure below), you might have forgotten to run
script 15 and 16 for app02. If so, please try:

```bash
./15-solution2-xlb-GFE3-traffic-split.sh  app02
./16-solution2-test-by-curling-N-times.sh app02
```

<img src="https://github.com/palladius/clouddeploy-platinum-path/blob/main/doc/gke-ui-with-3apps-but-only-app01-sol2.png?raw=true" alt="we forgot solution 2 plumbing for app02" align='center' />


## Other great scripts

I've disseminated `bin/` with scripts that I utilized for testing my solutions. You might find them useful (and send me
a PR to fix the errors ). Some examples:

### bin/curl-them-all

    🐧ricc@derek:$ bin/curl-them-all

<img src="https://github.com/palladius/clouddeploy-platinum-path/blob/main/doc/curl-them-all-screenshot.png?raw=true" alt="curl-them-all script example" align='center' />


### bin/kubectl-$STAGEZ

I've created a few scripts to call the 3 kubernetes clusters with right context:

```bash
bin/kubectl-dev
bin/kubectl-staging          # Note this is the same as DEV but with different namespace.
bin/kubectl-canary
bin/kubectl-prod
bin/kubectl-canary-and-prod  # C+P
bin/kubectl-triune           # 4 stages (*)
```

(*) *Why triune?* Good question. Well, like in all great bands, initially
   [there were three](https://en.wikipedia.org/wiki/...And_Then_There_Were_Three...). Plus, Italians
   are quite religious.

You can invoke these scripts in two ways:

* `VANILLA=false` (**default**). This will prepend the cluster in case you risk to be confused by WHERE your pod/service is.
* `VANILLA=true` (you need to set it explicitly). This will remove my *magic prepends* and is useful in case when you
  need the original ouput, for instance inside scripts which need verbatim (think of a `awk .. $4` which becomes an
  `awk .. $5`, very annoying).

  Example:

```bash
# Enabling Vanilla, your output is good to go for your scripts
ricc@derek:$ 🐼 VANILLA=TRUE bin/kubectl-prod get svc | egrep -v none
NAME                            TYPE           CLUSTER-IP    EXTERNAL-IP      PORT(S)          AGE
app01-kupython                  LoadBalancer   10.21.1.102   34.76.200.115    8080:31005/TCP   49d
app02-kuruby                    LoadBalancer   10.21.3.105   146.148.30.110   8080:30506/TCP   73d
app03-kunode                    LoadBalancer   10.21.3.54    146.148.6.155    80:31216/TCP     44d
app03-kunode-canary             LoadBalancer   10.21.3.245   34.76.33.177     80:31101/TCP     44d
# By doing nothing, your output gets prepended the cluster where your entity sits. Particularly nice
# if invoked with TRIUNE which iterate kubectl on all 4 stages.
$ bin/kubectl-triune get deployment 2>/dev/null
[DEV]  NAME             READY   UP-TO-DATE   AVAILABLE   AGE
[DEV]  app-goldennode   0/1     1            0           23d
[DEV]  app01-kupython   1/1     1            1           73d
[DEV]  app02-kuruby     1/1     1            1           73d
[DEV]  app03-kunode     1/1     1            1           44d
[STAG] NAME                                 READY   UP-TO-DATE   AVAILABLE   AGE
[STAG] app01-kupython                       1/1     1            1           73d
[STAG] app01-kupython-sol1d-scriptdump      0/1     1            0           48d
[STAG] app02-kuruby                         1/1     1            1           73d
[STAG] app02-kuruby-sol1d-ciofeca           0/1     1            0           48d
[STAG] app03-kunode                         1/1     1            1           44d
[STAG] sol1d-dmarzi-store-v1-depl           1/1     1            1           49d
[STAG] sol1d-dmarzi-versionedpy22-v1-depl   0/1     1            0           48d
[CANA] NAME             READY   UP-TO-DATE   AVAILABLE   AGE
[CANA] app01-kupython   1/1     1            1           73d
[CANA] app02-kuruby     1/1     1            1           49d
[PROD] NAME                  READY   UP-TO-DATE   AVAILABLE   AGE
[PROD] app01-kupython        4/4     4            4           49d
[PROD] app02-kuruby          4/4     4            4           73d
[PROD] app03-kunode          4/4     4            4           44d
[PROD] app03-kunode-canary   1/1     1            1           44d
# Another useful test: gets solution2 stuff in PROD
$ bin/kubectl-prod get all,gateway,httproute | grep sol2
```

### bin/troubleshoot-solutionN

When trying to see if a solution worked or not, I wanted to *script the gcloud out of it* to get IP addresses and such.

These four scripts have a lot of interesting logic and are read-only so you can always launch them lightheartedly.

* `bin/troubleshoot-solution2` (**working**) This checks **Solution B** (the complex one)
* `bin/troubleshoot-solution4` (**working**) This checks the **Solution A** (the simple one)

There are also two other scripts which I left there in case you want to dig into solution 1 and 3:

* bin/troubleshoot-solution0-ilb (*unmaintained*). This checks solution 0 (then renamed solution 3), with Internal LB.
* bin/troubleshoot-solution1 (*unmaintained*). This checks a solution that I haven't documented (it's under examples/)

### bin/{rcg, lolcat, proceed_if_error_matches}

These are convenience scripts:

* `rcg` is a perl script I copied from StackOverflow which colorizes some matched REGEXEs. Useful to colorize a 200 in
  green and a 404 in red:

<img src="https://github.com/palladius/clouddeploy-platinum-path/blob/main/doc/curl-them-all-screenshot.png?raw=true" alt="curl-them-all script example" align='center' />

* `lolcat` is a placeholder script in case you insist on not installing `gem install lolcat` as my colleagues asked me to.
  Hwoever, what's life without ❤️ Ruby and some 🎨 color? Exactly.
* `proceed_if_error_matches` is the heart of my bash scripts. I wanted them to stop at the first error, so I wouldn't
  create infrastcuture which depended on something else which wouldn't be there. However, this left another problem:
  you can't create twice a bucket or a GKE cluster, gcloud will tell you it already exists and doesn't support a
  well needed "--ignore-if-exist" flag. Therefore, I've created this scripts since most of the time the output looks lik
  "blah blah blah already exists".


## Possible Errors

### E001 Quota Issues

You might incur quota issues. To see if Kubernetes is somewhat clogged, try:

    `🐧$ bin/kubectl-triune get pods`

And look for pending pods. This might be a signal you’re out of CPUs/RAM in your region.
This awesome script just iterates kubectl over the 3 clusters we’ve created.


Some tips:
* Pick a region with high capacity (eg us-central1 , europe-west1, ..). In doubt, pick the first/top in your continent.
* Check your [quota page](https://console.cloud.google.com/iam-admin/quotas) and ask for capacity to be increased.
  Usually this takes less than an hour to take effect - depending on a number of factors (your reputation, region
  capacity, …). Select orange things on top, click “edit quotas” and add your personal data for our Support reps to help
  you out (it's free!).

### E002 source: .env.sh: file not found

I’ve heard from a few colleagues that they get this kind of error:

```bash
$ 00-init.sh: line 3: source: .env.sh: file not found
```

**First** make sure the file exists:

    `cat.env.sh`

If file exists and you still get the error, chances are the problem is in your shell (‘source’ is a bash builtin).
While my scripts work on default Linux and Mac installations, I believe some *n*x systems might have a different shell
by default (zsh? sh? ash?). In this case, try to explicitly call **bash**, like for example:

```bash
$ bash 00-init.sh
$ bash 01-set-up-GKE-clusters.sh
```

Also, for troubleshooting purposes, check this:

```bash
$ echo $SHELL
/bin/bash
```

### E003 Some dependencies missing

If you get some error on script YY which is fixed by some previous script XX, chances are that one of those scripts
didn’t complete successfully.
That’s why I ensure that every script ends with a [touch](https://man7.org/linux/man-pages/man1/touch.1.html)
“`.executed_ok.<SOMETHING>`”.
Try this and see if some numbers are missing:

    `make breadcrumb-navigation`

  <img src="https://github.com/palladius/clouddeploy-platinum-path/blob/main/doc/breadcrumbs-screenshot.png?raw=true" alt="Carlessian Breadcrumbs" align='center' />

```bash
$ make breadcrumb-navigation
I hope you're a fan of Hansel and Gretel too. As a Zoolander fan, I am.
-rw-r--r-- 1 ricc ricc 0 Jul  9 20:39 .executed_ok.00-init.sh.touch
-rw-r--r-- 1 ricc ricc 0 Jul  9 20:41 .executed_ok.01-set-up-GKE-clusters.sh.touch
-rw-r--r-- 1 ricc ricc 0 Jul  9 20:43 .executed_ok.03-configure-artifact-repo-and-docker.sh.touch
```

In this example, you see that you have probably skipped the script #02 and you might want to try rerun it. I’ve made a
serious effort to make those scripts
[reentrant](https://www.mathworks.com/help/rtw/ug/what-is-reentrant-code-2d70b58a9a46.html) (or at least,
re-invokable multiple times). So it shouldn’t be a problem to go back and re-execute the previous ones.

*Example*. If you have a list of completed 1 2 3 5 6, I would re-execute starting from the first gap and re-execute the
correct ones after it, so: **4 5 6**.

### E004 MatchExpressions LabelSelectorRequirement field is immutable

*(This is for kubectl beginners like me)*

You aren’t probably going to see this, but I saw this many times. If you change your labels and selectors over time,
your Deployment #1 will probably work, but subsequent ones will fail if some labels have changed due to immutability of
labels. The easy solution is to kill the deployment on the GKE UI and re-trigger the deployment.
This is a tricky bug since it won’t occur the first time.

Sample error:

```bash
2022-07-16 15:17:34.704 CEST Starting deploy...
2022-07-16 15:17:37.280 CEST - service/app01-kupython configured
2022-07-16 15:17:37.373 CEST - The Deployment "app01-kupython" is invalid: spec.selector: Invalid value: v1.LabelSelector{MatchLabels:map[string]string{"app":"app01-kupython", "application":"riccardo-cicd-platinum-path", "github-repo":"palladius-colon-cicd-platinum-path", "is-app-in-production":"bingo", "platinum-app-id":"app01", "ricc-awesome-selector":"canary-or-prod", "ricc-env":"prod", "tier":"ricc-frontend-application"}, MatchExpressions:[]v1.LabelSelectorRequirement(nil)}: field is immutable
2022-07-16 15:17:37.376 CEST kubectl apply: exit status 1
```

Solution: it’s simple: kill the deployment and recreate it.

* **Kill the problematic deployment**. Super easy: `$ bin/kubectl-triune delete deployment app01-kupython app02-kuruby`.
  This will kill the app01/app02 deployments in all 3 GKE clusters for all 4 targets (wow). Probably you just need a
  subset of this 8-kill-in-a-row.
* Restore the deployment. This is harder, if its dev or staging I just lazily bump the version in my repo
  (eg vim apps/app01/VERSION -> from 42.42 to 42.43bump) , commit and push. This will force a new build and deploy to
  dev/staging. Otherwise you can leverage Cloud Deploy to redeploy the same release. This should be faster.

  <img src="https://github.com/palladius/clouddeploy-platinum-path/blob/main/doc/cd-redeploy.png?raw=true" alt="How to redeploy a release" align='center' />

### E005 missing gcloud config

This error only came up with Cloud Shell. I believe that when your Shell environment times out, while it might remember the project id, the gcloud config forgets other important information.

ERROR: (gcloud.deploy.releases.list) Error parsing [delivery_pipeline].
The [delivery_pipeline] resource is not properly specified.
Failed to find attribute [region]. The attribute can be set in the following ways:
- provide the argument `--region` on the command line
- set the property `deploy/region`

Solution: run a second time the setup script:

    `$ ./00-init.sh`


### E006 Miscellaneous errors

* gcloud crashed (AttributeError): 'NoneType' object has no attribute 'SelfLink' => See
  [Stackoverflow](https://stackoverflow.com/questions/57031471/gcloud-crashed-attributeerror-nonetype-object-has-no-attribute-revisiontem)

* Some Org policies might prevent you from achieving your goal. For instance, a `constraints/compute.vmExternalIp`
  policy would prevent your GKE clusters to be set up with public IPs. Feel free to file a PR to fix this which is
  beyond the scope of this demo.

### E007 Code is still broken!

I've extensively ran the code 8 times. But bugs happen. Try these:

* Download / use the v.0 version https://github.com/palladius/clouddeploy-platinum-path/releases/tag/1.0
* Make sure your local code is always up to date to latest/stablest version. Particularly your fork could have been from
  former/unfixed code.
* If everything still fails, please file a bug with a paste of your error, and possibly a list of your *breadcrumbs*.

## Additional readings

* [Traffic management overview for global external HTTP(S) load balancers](https://cloud.google.com/load-balancing/docs/https/traffic-management-global)
* Check for Envoy-based Global Load Balancer kubernetes support through Gateway API: see [this table](https://cloud.google.com/load-balancing/docs/features#backends).
