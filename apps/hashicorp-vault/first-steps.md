<style>
table {
    border-collapse: collapse;
}
table, th, td {
   border: 0px;
}
</style>



# Connecting to an external Hashicorp Vault. 


### Installing the Vault agent in OCP.  


### 1) Create a namespace where you would like the vault agent to be installed. 

```
oc create namespace hashicorp-vault
```

### 2) Head over to the dev console 

![](img/step1.png) 

 ![](img/one.png )  namespace from step 1 
 
 ![](img/two.png )  select the link 


### 3) Install the Vault via Helm
![](img/step2.png) 

 ![](img/one.png )   search for the vault helm chart 
 
 ![](img/two.png )   select the chart repository  
 
 ![](img/three.png ) install the vaul agent controller 


### 4) Configure the server 
![](img/step3.png) 

 ![](img/one.png )     enter the address of the vault server  

 ![](img/two.png )     check the OpenShift box 
 
 ![](img/three.png )   enable TLS 
 
 ![](img/four.png )    install the controller 

![](img/step4.png) 

  confirm the controller has been deployed 




### Setting up Vault with the CLI.  


Create some environment variables with the Vault address and Vault token 

```
$ export VAULT_ADDR="" 
$ export VAULT_TOKEN=""
```

Create a namespace and set an environment variable 

```
$ vault namespace create ocp   
$ export VAULT_NAMESPACE="admin/ocp" 
```

Enable the kv2 engine and define a path 

```
$ vault secrets enable -path=secrets kv-v2
```

Enable the Kubernetes auth engine:

```
$ vault auth enable admin/ocp/kubernetes
```


Create a secrets: 

```
$ vault kv put secrets/my-app/dev/database username="db-username-retrieved-from-hashi" password="db-password-retrieved-from-hashi"             
```

Verify the secret:

```
$ vault kv get secrets/my-app/dev/database 
```

# for envars example (nodejs-demo)
$ vault kv put secrets/my-app/dev/database username="db-username-retrieved-from-hashi" password="db-password-retrieved-from-hashi"             
$ vault kv get secrets/my-app/dev/database 

# for templates example (hello-world)
$ vault kv put secrets/my-app/dev/contact title="Contact us" telephone="+(44) 555-234545" 
$ vault kv put secrets/my-app/dev/index title="Home page" password="The secret from hashi vault" 

$ vault kv get secrets/my-app/dev/database 


$ oc create secret generic vault-agent-template-web-pages --from-file=index.html.ctmpl=./index.html --from-file=contact.html.ctmpl=./contact.html \
     --dry-run=client -o yaml > vault-agent-template-web-pages.yaml

Define a policy:

```
$ vault policy write my-app-secrets - <<EOF
path "secrets/data/my-app/dev/*" {
  capabilities = ["read" , "list"]
}
EOF
```

Configure the role:

```
$ vault write auth/kubernetes/role/my-app \
    bound_service_account_names=nodejs-demo-hashi,hello-world-app \
    bound_service_account_namespaces=nodejs-demo,hello-world \
    policies=my-app-secrets \
    ttl=24h
```

To set up the auth method in Vault using the service account name that was used when initially installed. We need to extract the JWT token from the secret.
Let's find out the name of the secret it is the mountable secret with the *-token-* name

```
$ oc describe  sa vault -n hashicorp-vault         
Name:                vault
Namespace:           hashicorp-vault
Labels:              app.kubernetes.io/instance=vault
                     app.kubernetes.io/managed-by=Helm
                     app.kubernetes.io/name=vault
                     helm.sh/chart=vault-0.22.0
Annotations:         meta.helm.sh/release-name: vault
                     meta.helm.sh/release-namespace: hashicorp-vault
Image pull secrets:  vault-dockercfg-flp6c
Mountable secrets:   vault-token-x6hrv
                     vault-dockercfg-flp6c
Tokens:              vault-token-4ltc7
                     vault-token-x6hrv
Events:              <none>
```

Next export the JWT token, the Kubernetes API CA certificate and the Kubernetes endpoint address: 

```
$ export JWT_TOKEN=$(oc get secret vault-token-x6hrv -n hashicorp-vault -o jsonpath='{.data.token}' | base64 -d)
$ export KUBE_CA_CRT=$(oc get cm kube-root-ca.crt -n openshift-config -o jsonpath='{.data.ca\.crt}') 
$ export KUBE_HOST=$(oc config view --raw --minify --flatten --output 'jsonpath={.clusters[].cluster.server}')
```

Use these variables to write auth config to Vault: 

```
$ vault write auth/kubernetes/config \
     token_reviewer_jwt="$JWT_TOKEN" \
     kubernetes_host="$KUBE_HOST" \
     kubernetes_ca_cert="$KUBE_CA_CRT" 
```

Verify the config: 

```
$ vault read auth/kubernetes/config
```