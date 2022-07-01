
# app01 
Python had two rpoblems:

* until 5min ago, the prod v1.4 survived but it was called `Web` which sucks. 
  I just upgraded so all Apps are called `app01-kupython`.
* kustomize came late for app01. I experimented more on ruby app02 and piggybacked this in the end.
  Fattosta(TM) that i didnt have the awesome selector which is insterad available for ruby.

# app02

App02 has kustomize since the beginning and i built this awesome thing called

     ricc-awesome-selector: canary-or-prod

so i can trivially use this. I need to do the same for python and make it sure its different
so something like

     ricc-awesome-selector: app01-canary-or-prod

unless i can do a double selection in which case it seems obviouser (!) to do this:

     ricc-awesome-selector: canary-or-prod
     app_id: app01

so the second is  

     ricc-awesome-selector: canary-or-prod
     app_id: app02

