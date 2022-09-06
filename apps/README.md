Every app is a "module" which can be called and developed independently.
Each app will have a single Cloud Deploy pipeline and Cloud Build trigger.

* app01/ (Python) vanilla
* app02/ (Ruby)   playing with Kustomize taking inspiration from Alex B.
* app03/ (Node.js) Demonstrating simple single-cluster solution (by Alex)

`App01` and `App02` are used for the Complex (two cluster for PROD anc CANARY) solution,
while `App03` is used for the simple one.

## Tips on using Skaffold profiles

For base:

    skaffold render --module='app01'

For production:

    skaffold render --module="app01" --profile="prod"
