GXLB manage traffic but cannot manage traffic splitting

in this example, in order to check the canary deployment, the /canary url should be used.

normal traffic
```
curl -H "host: store.example.io" VIP/
```

canary traffic
```
curl -H "host: store.example.io" VIP/canary
```
