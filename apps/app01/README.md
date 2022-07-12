This code was taken from https://github.com/GoogleContainerTools/skaffold/
under `examples/buildpacks-python` folder.

### Original Example: buildpacks (Python)

These are the original docs for the original code.

[![Open in Cloud Shell](https://gstatic.com/cloudssh/images/open-btn.svg)](https://ssh.cloud.google.com/cloudshell/editor?cloudshell_git_repo=https://github.com/GoogleContainerTools/skaffold&cloudshell_open_in_editor=README.md&cloudshell_workspace=examples/buildpacks-python)

This is an example demonstrating:

* **building** a Python app built with [Cloud Native Buildpacks](https://buildpacks.io/)
* **tagging** using the default tagPolicy (`gitCommit`)
* **deploying** a single container pod using `kubectl`

## Riccardo customization

* the manifests have grown a bit, leveraging Kustomize and skaffold to prep 4 slightly different manifests
  based on the target they refer to (dev / staging / canary / prod). 

## History

* 20220711 2.3 Adding `project.toml` to test ignoring README in builds :) and ditto with `.gcloudignore`
* 20220711 2.2 Major Kustomize rewrites - thanks Alex! 
* 20220711 2.1 Lot of useless version bumps just to test CD. Sorry folks.
* 20220614 2.0 Renamed to kupython -> breaking change.
* 20220614 1.7 Added python emoji 🐍 in frontend - to test GKE backend changes..
* 20220610 1.4 changed fav color to TEAL and added in HTML as background to add some color to the app :) 
* 20220610 1.3 Installed locally and finally fixed. (1) 
* 20220609 1.2 was broken
* 20220609 1.0alpha it worked! I know cos its still running in prod! https://screenshot.googleplex.com/7Yqd6ShdDsqF9KA

(1) Sorry I dont know how to use the magic modules locally so I had to install conda locally and do the effort myself 


