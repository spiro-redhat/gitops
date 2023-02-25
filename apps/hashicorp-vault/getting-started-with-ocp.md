Add step 1 - 4 pngs 

````
$ oc describe sa vault -n hashicorp-vault                                                          
Name:                vault
Namespace:           hashicorp-vault
Labels:              app.kubernetes.io/instance=vault
                     app.kubernetes.io/managed-by=Helm
                     app.kubernetes.io/name=vault
                     helm.sh/chart=vault-0.23.0
Annotations:         meta.helm.sh/release-name: vault
                     meta.helm.sh/release-namespace: hashicorp-vault
Image pull secrets:  vault-dockercfg-csqn6
Mountable secrets:   vault-dockercfg-csqn6
                     vault-token-jx9g6
Tokens:              vault-token-f2pth
                     vault-token-jx9g6
Events:              <none>
```

Make now of the vault-token name that is listed as a mounted secret. In the example above it is `vault-token-jx9g6`


```
AGENT_JWT_TOKEN=$(oc get secret vault-token-jx9g6 -n hashicorp-vault -o jsonpath='{.data.token}')
```

