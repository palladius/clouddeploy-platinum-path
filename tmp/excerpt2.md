<!-- Output copied to clipboard! -->

<!-----
NEW: Check the "Suppress top comment" to remove this info from the output.

Conversion time: 3.246 seconds.


Using this Markdown file:

1. Cut and paste this output into your source file.
2. See the notes and action items below regarding this conversion run.
3. Check the rendered output (headings, lists, code blocks, tables) for proper
   formatting and use a linkchecker before you publish this page.

Conversion notes:

* GDC version 1.1.19 r30
* Fri Aug 26 2022 04:34:03 GMT-0700 (Pacific Daylight Time)
* Source doc: https://docs.google.com/open?id=1yRxlNv41mNVVi-JHtmdOoYhvtlpULsdd4fcG8Nq5TZs
----->


<p style="color: red; font-weight: bold">>>>>  GDC alert:  ERRORs: 0; WARNINGs: 0; ALERTS: 5.</p>
<ul style="color: red; font-weight: bold"><li>See top comment block for details on ERRORs and WARNINGs. <li>In the converted Markdown or HTML, search for inline alerts that start with >>>>  GDC alert:  for specific instances that need correction.</ul>

<p style="color: red; font-weight: bold">Links to alert messages:</p><a href="#gdcalert1">alert1</a>
<a href="#gdcalert2">alert2</a>
<a href="#gdcalert3">alert3</a>
<a href="#gdcalert4">alert4</a>
<a href="#gdcalert5">alert5</a>

<p style="color: red; font-weight: bold">>>>> PLEASE check and correct alert issues and delete this message and the inline alerts.<hr></p>



## Excerpt #2 from WIP doc  go/ricc-cd-canary-doc


### 06 Manual Import repo (important) [was 06.5]

[DOC\_REFACTOR\_IN\_PROGRESS] Part of this has been moved to before the 00 script.

**<span style="text-decoration:underline;">Note</span>**: This is the only manual process since there’s no way via gcloud to make it happen yet.

At this point you need a repo which is ever changing, so you can’t use my personal repo. You have a number of options and I suggest to find the one that best suits you:



1. **[ALREADY DONE AFTER AUGUST REFACTORING] Fork my github repo** under your github user ([example](https://github.com/aablsk/clouddeploy-platinum-path)), and then sync that to Google Cloud Repository (GCR). This is probably the easiest way to get started. **<span style="text-decoration:underline;">This requires a Github account</span>**.
2. Create a brand new repo under GCR and use it. [deprecated]
3. Sync some other repo with a few applications under some folders and heavily tweak the next script Script #7 (`07-create-cloud-build-triggers.sh`).

**Note**. Depending on what you do, you might need to tweak the script #7.

I strongly encourage you to read Cloud Build documentation to learn all about the underlying ~~magic~~ technology: https://cloud.google.com/build/docs/automating-builds/build-repos-from-github



1. New URL will look like this: https://github.com/**[aablsk/clouddeploy-platinum-path](https://github.com/aablsk/clouddeploy-platinum-path)** [different username]
2. Make sure your .env.sh has YOUR github id (not mine) for this step :)
3. Open Cloud Developer Console > Cloud Build > Triggers: https://console.cloud.google.com/cloud-build/triggers
    1. [TODO Nate confirm] Make sure that **GLOBAL** region is selected.
    2.

<p id="gdcalert1" ><span style="color: red; font-weight: bold">>>>>  GDC alert: inline image link here (to images/image1.png). Store image on your image server and adjust path/filename/extension if necessary. </span><br>(<a href="#">Back to top</a>)(<a href="#gdcalert2">Next alert</a>)<br><span style="color: red; font-weight: bold">>>>> </span></p>


![alt_text](images/image1.png "image_tooltip")

4. Click on **Connect repository _(bottom of page)_**:



<p id="gdcalert2" ><span style="color: red; font-weight: bold">>>>>  GDC alert: inline image link here (to images/image2.png). Store image on your image server and adjust path/filename/extension if necessary. </span><br>(<a href="#">Back to top</a>)(<a href="#gdcalert3">Next alert</a>)<br><span style="color: red; font-weight: bold">>>>> </span></p>


![alt_text](images/image2.png "image_tooltip")




5. “Select Source” > “**GitHub (Cloud Build GitHub App)” **and click** “continue”.**.
    3. **<span style="text-decoration:underline;">Note</span>** I’ve also tried the Github Legacy Beta - it works very well if you then want to check out the code and work from Google side of things (eg privatize public code). But the solution provided by me to you have one less piece of “furniture” you need to care about. I mention this in case you don't have a github repo, in which case you might prefer to just clone my repo into your GCR and link Cloud Build to that. In that case see the commented code in the 07 script - took me 3 hours to find out with trial and errors.  \


<p id="gdcalert3" ><span style="color: red; font-weight: bold">>>>>  GDC alert: inline image link here (to images/image3.png). Store image on your image server and adjust path/filename/extension if necessary. </span><br>(<a href="#">Back to top</a>)(<a href="#gdcalert4">Next alert</a>)<br><span style="color: red; font-weight: bold">>>>> </span></p>


![alt_text](images/image3.png "image_tooltip")

6. **Authenticate** to github with your identity.
7. You might be prompted to install **Google Cloud Build** **github app** => do it.
8. Select repository  and hit **CONNECT**.
    4. 1. enter the **username**
    5. 2. select the **repo**, likely ”clouddeploy-platinum-path“
    6. 3. Tick the Terms of Service box
    7. 4. Press CONNECT
    8.

<p id="gdcalert4" ><span style="color: red; font-weight: bold">>>>>  GDC alert: inline image link here (to images/image4.png). Store image on your image server and adjust path/filename/extension if necessary. </span><br>(<a href="#">Back to top</a>)(<a href="#gdcalert5">Next alert</a>)<br><span style="color: red; font-weight: bold">>>>> </span></p>


![alt_text](images/image4.png "image_tooltip")

9. Click DONE. (no you don't need to create a trigger, since we do it programmatically from script 07)
10. And you’re done 🎉! Your repo should be now connected and available in Cloud Build.

To check that everything was good, you can list it via this URL: https://console.cloud.google.com/cloud-build/repos;region=global and see something like this with different user name:



<p id="gdcalert5" ><span style="color: red; font-weight: bold">>>>>  GDC alert: inline image link here (to images/image5.png). Store image on your image server and adjust path/filename/extension if necessary. </span><br>(<a href="#">Back to top</a>)(<a href="#gdcalert6">Next alert</a>)<br><span style="color: red; font-weight: bold">>>>> </span></p>


![alt_text](images/image5.png "image_tooltip")


**<span style="text-decoration:underline;">Note</span>**: “gcloud source repos list” won’t work since there’s no code on google, just some sort of inter-site commit hook.

**<span style="text-decoration:underline;">Note</span>**. I noticed there’s a slight difference in cloning a repo in GCR, therefore I left the command commented in the code for posterity, should you need it someday:


        #gcloud alpha builds triggers create cloud-source-repositories \


        #   --repo=$GITHUB\_REPO\_OWNER/clouddeploy-platinum-path --branch-pattern='.\*' \


        #   --description="[$TEAM\_NUMBER] CB trigger from CLI for $TEAM\_NAME module" --included-files="${SRC\_SUBFOLDER}\*\*,\*.yaml" \


        #   --build-config cloudbuild.yaml --substitutions="\_DEPLOY\_UNIT=$TEAM\_NAME,\_FAVORITE\_COLOR=$FAV\_COLOR" \


        #   --region=$REGION --name $TEAM\_NUMBER-CLIv$TRIGGERVERSION-$TEAM\_NAME
