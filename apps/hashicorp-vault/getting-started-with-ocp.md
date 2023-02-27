The DevOps report 2023 revealed some interesting developments in the evolution of devops as a practice.  Of most signifance was the emergence of the plaform or more specifically  platforom engineering. Platform engineer of the DevOps  the concept of DevOps, iIt amounts to an infrastructure build around product awareness and manifesting itself as an ecosystem of self-serving capabilities allowing   in particular to enable enterprises perform more effectively both within in their IT functions and by adopting a DevOps focused culture elsewhere, within their operations. Amongst the key finds it found that platform engineering had an impact on organsations to operate more effectively at scale whilst also benefitting the entire organisation with more efficient product delivery through better IT and security systems, more standardisation and less duplication of effort. A platform, according to the report is an ecosystem of self-service products that continuosly evolve to meet user needs. It is intended to  evolve with those needs through shared collaboration of organisational values and practices. The wider adoption of the platform should take the form of internal evangilsm rather than from top down mandates. The benefits should be self evident and adoption, a natural choice.      


This blog will discuss how a self-serving encryption may be incorporated as a platform service within your organisation or enterprise. The aim is to place address the governance concerns of various units within the organsational through the implementation of certain boundaries. Reducing the cognitive load of platform and value stream teams is also a core design goal as this allows your teams to focus on what matters most, your business.  

Hashicorp Vault is used as an example and I will show it can be integrated into OpenShift to provide encryption as a service to your workloads. The examples in this blog are for demonstrated purposes only and are no way assuming their relevance for any specfic context. They should however be sufficiently adaptable to meet common businss scenarios. 

Enterprise Vault introduced the concept of namespaces, it provides a means to create vaults within vault, each having their own encryption engine and storage backends. We are going to use this feature to create three namespaces: 

1) OCP - A namespace dedicated to workloads running in OpenShift, it will use the  
3) Users - A namespace dedicated to users to store their own key value secrets. They will use the CubbyHole facility and no storage backends. Authentication should be handled via SAML and OAu.    
2) Databases 



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
