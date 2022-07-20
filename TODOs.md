# For v1 release

* P0. Before releaseing, resolve all `TODO_IMPORTANT`: rgrep TODO_IMPORTANT .

* P1. Automate Cloud Build Repo sync to GCR (currently in gcloud alpha status)

* P4. Set up service account in 00-init and use it for the rest. Probably it would be between a 00 and a 01 setup.
      If it works, backfill it to `codelabba.rb`

* P3. Use `envsubst` instead. (33% done)


# For v2 release

* P2. Move bash to Terraform.
