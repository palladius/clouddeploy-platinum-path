Every app is a "module" which can be called and developed independently.
Each app will have a single Cloud Deploy pipeline and Cloud Build trigger.

* app01/ - python, vanilla
* app02/ - ruby, pklaying with Kustomize taking isnpiration from abielski


## Alex wise words for using Skaffold:

For base

    skaffold render --module=app01

For production

    skaffold render --module=app01 --profile=production