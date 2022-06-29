
* P1. Automate Cloud Build Repo sync to GCR (currently in gcloud alpha status)

* P2. Move bash to Terraform.

* P2. Create under k8s/ a number of WORKING deployment dirs. Possible taconomy could be: 

    k8s/
        prod/
            deployment-strategy1/ # this works
            
        test/
            deployment-strategy2/  # still broken
            deployment-strategy3/  # or half working
    
    They should have a Makefile in the root dir since some might have 2 subdirs for multicluster setup (eg MCS).
            