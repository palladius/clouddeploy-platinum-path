
* 2022-07-15 I've found out that by simplifying my skaffold configs I had a conflict between DEV and STAG:
  they were existing in same cluster with same name and same namespace. You either inject a name suffix or
  you use a namespace, and Alex sugegsted the second one. Also he suggested to change DEV not STAGING, as
  you want STAG to be as close as possible to CAN and PRD. Now I'm going to do the same on app01 which
  keeps failing.
