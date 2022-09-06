Every app is a "module" which can be called and developed independently.
Each app will have a single Cloud Deploy pipeline and Cloud Build trigger.

* `app01/` (*Python*) vanilla app
* `app02/` (*Ruby*)   playing with Kustomize taking inspiration from Alex B.
* `app03/` (*Node.js*) Demonstrating simple single-cluster solution (by Alex)

`App01` and `App02` are used for the Complex (two cluster for PROD anc CANARY) solution,
while `App03` is used for the simple one.

## On the apps

While the apps could be completely different, they have a thing in common: they respond to two endpoints:

* `/` a verbose page containing a lot of ENV information, more verbose and useful to troubleshoot.
* `/statusz` (Google style). a single line which contains very little info, used to demonstrate the canary deployment by
  just `curl`ing the same endpoint multiple times. Example outputs:
  * `app=app01 version=2.25c target=prod emoji=🐍`
  * `app=app02 emoji=💎 target=prod version=2.0.8`
  * `app=app03 version=1.0.2 target=prod emoji=🧊`


## Tips on using Skaffold profiles

For base:

    skaffold render --module='app01'

For production:

    skaffold render --module="app01" --profile="prod"
