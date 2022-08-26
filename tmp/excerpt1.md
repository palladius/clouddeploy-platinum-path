<!-- Output copied to clipboard! -->

<!-----
NEW: Check the "Suppress top comment" to remove this info from the output.

Conversion time: 2.905 seconds.


Using this Markdown file:

1. Cut and paste this output into your source file.
2. See the notes and action items below regarding this conversion run.
3. Check the rendered output (headings, lists, code blocks, tables) for proper
   formatting and use a linkchecker before you publish this page.

Conversion notes:

* GDC version 1.1.19 r30
* Fri Aug 26 2022 04:36:22 GMT-0700 (Pacific Daylight Time)
* Source doc: https://docs.google.com/open?id=1nLX9QjJPbo6SqRK-NKXPD77oJFq0cee3YDy2035A6Ik&resourcekey=0-w5zcMLwzox2fnY18-m1lUQ
----->


<p style="color: red; font-weight: bold">>>>>  GDC alert:  ERRORs: 0; WARNINGs: 0; ALERTS: 2.</p>
<ul style="color: red; font-weight: bold"><li>See top comment block for details on ERRORs and WARNINGs. <li>In the converted Markdown or HTML, search for inline alerts that start with >>>>  GDC alert:  for specific instances that need correction.</ul>

<p style="color: red; font-weight: bold">Links to alert messages:</p><a href="#gdcalert1">alert1</a>
<a href="#gdcalert2">alert2</a>

<p style="color: red; font-weight: bold">>>>> PLEASE check and correct alert issues and delete this message and the inline alerts.<hr></p>



## Excerpt #1 from WIP doc  go/ricc-cd-canary-doc


## Setting things up

All scripts in the root directory are named in numerical order and describe the outcome they’re intended to achieve.

Before executing any bash script, they all source a .env.sh script which you’re supposed to create (from the .env.sh.dist (file) and maintain somewhere else (I personally use [git-privatize](https://github.com/palladius/sakura/blob/master/bin/git-privatize) and symlink it from/to another private repo).



1. Choose your environment.
    1. You can use **Google Cloud Shell** (leveraging the awesome integrated editor). This has been tested there.
    2. Linux machine where you’ve installed gcloud.
    3. Max OSX with bash v5 or more (to support hashes). To do so, just try `brew install bash` and make sure to use the new BASH path.
2. **[Fork](https://github.com/palladius/clouddeploy-platinum-path/fork)** the code repo:
    4. Go to https://github.com/palladius/clouddeploy-platinum-path/
    5. Click “**Fork**” to fork the code under your username.
    6.

<p id="gdcalert1" ><span style="color: red; font-weight: bold">>>>>  GDC alert: inline image link here (to images/image1.png). Store image on your image server and adjust path/filename/extension if necessary. </span><br>(<a href="#">Back to top</a>)(<a href="#gdcalert2">Next alert</a>)<br><span style="color: red; font-weight: bold">>>>> </span></p>


![alt_text](images/image1.png "image_tooltip")
 \
 \
New URL will look like this: https://github.com/**[daenerys/clouddeploy-platinum-path](https://github.com/aablsk/clouddeploy-platinum-path)** [with your username]. You’ll need this username in a minute.
    7. **<span style="text-decoration:underline;">Note</span>** that if you don’t have a github account (and you don’t want to create one), you can just fork my repo in your GCR - more instructions later at **step 06 below**. \

3. [**optional**] Install a colorizing gem. If you won’t do it, there’s a lolcat fake wrapper in bin/ (added to path in init script). But trust me, it’s worth it (unless you have **no**

<p id="gdcalert2" ><span style="color: red; font-weight: bold">>>>>  GDC alert: inline image link here (to images/image2.png). Store image on your image server and adjust path/filename/extension if necessary. </span><br>(<a href="#">Back to top</a>)(<a href="#gdcalert3">Next alert</a>)<br><span style="color: red; font-weight: bold">>>>> </span></p>


![alt_text](images/image2.png "image_tooltip")
Ruby installed). \
 \
gem install lolcat \

4. Copy the env template to a new file that we’ll modify  \
 \
cp .env.sh.dist .env.sh

 \



5. Open .env.sh and substitute the proper values for any variable that has # changeme next to it. (If you’re on Cloud Shell, you can try **edit .env.sh **to let the UI editor shine). For instance:
    8. **PROJECT\_ID**. This your string (non-numeric) project id. [More info on projects](https://cloud.google.com/resource-manager/docs/creating-managing-projects).
    9. **ACCOUNT _(eg, john.snow.kotn@gmail.com)_**. This is the email address of your GCP identity (who you authenticate with). Note that you can also set up a service account, but that’s not covered by this demo. In this case I’ll leave it with you to tweak the 00-init.sh script. On 🖥️ Cloud Shell, it's already set and you can get it from **gcloud config get account.**
    10. **GCLOUD\_REGION. **This is the region where 90% of things will happen. Please do choose a region with more capacity (my rule of thumb is to choose the oldest region in your geo, like us-central1, europe-west1, …). If unsure, pick our favorite: **[us-central1](https://cloud.google.com/compute/docs/regions-zones)**.
    11. **GITHUB\_REPO\_OWNER_ (eg, “daenerys”)_. **This should be the user you forked the repo with in (2). You can find it also in $ grep clouddeploy-platinum-path .git/config

     \
Optional fields: \


    12. **GCLOUD\_CONFIG _[optional]_**. This is the name of your [gcloud configuration](https://cloud.google.com/sdk/gcloud/reference/config/configurations). Pretty cosmetic, it becomes important when you have a lot of users/projects for different projects and you want to 📽️[keep them separated](https://www.youtube.com/watch?v=1jOk8dk-qaU). Try gcloud config configurations list to see your local environment. While not needed, I consider it a good practice to isolate your configs into gcloud configurations.
    13. **MY\_DOMAIN _[optional]_**. This is totally optional. Setting up Cloud DNS is very provider-dependent. If you have Cloud DNS already set up, you can be inspired by my script in [examples/14-setup-DNS-Riccardo-only.sh](https://github.com/palladius/clouddeploy-platinum-path/blob/main/examples/14-setup-DNS-Riccardo-only.sh) and tweak it to your liking. \

6. **Tip**: If you want to persist your personal .env.sh, consider using my script [git-privatize](https://github.com/palladius/sakura/blob/master/bin/git-privatize). If  you find a better way, please tell me - as I’ve looked for the past 5 years and this is the best I came up with.
