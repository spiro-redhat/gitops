


Add step 1 - 4 pngs 

Configure and test your connection to the vault server: 

export VAULT_ADDR="https://spi-hashi-cluster-0-public-vault-93264274.0c3c1a21.z1.hashicorp.cloud:8200"
export VAULT_NAMESPACE="admin"
export VAULT_TOKEN="hvs.CAESIGUTRpKegDnMk1ZIwvBR40lton0xEmfWpW4-PDSseGUXGigKImh2cy52c1dQNlJNd01aZE0xQVd6RDlCQzZJWGcuWjVtQW0Q0b0B"

create a namespace : 
```
$ vault namespace create ocp 
```
Output should look like this: 
```
Key                Value
---                -----
custom_metadata    map[]
id                 3zxdg
path               admin/ocp/
```



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
