
$ export VAULT_ADDR="" 
$ export VAULT_TOKEN=""

$ vault namespace create ocp   
$ export VAULT_NAMESPACE="admin/ocp" 
$ vault secrets enable -path=secrets kv-v2
$ vault auth enable admin/ocp/kubernetes

# for envars example (nodejs-demo)
$ vault kv put secrets/my-app/dev/database username="db-username-retrieved-from-hashi" password="db-password-retrieved-from-hashi"             
$ vault kv get secrets/my-app/dev/database 

# for templates example (hello-world)
$ vault kv put secrets/my-app/dev/index username="db-username-retrieved-from-hashi" password="db-password-retrieved-from-hashi"             
$ vault kv put secrets/my-app/dev/contact title="Contact us" telephone="+(44) 555-234545" 
$ vault kv put secrets/my-app/dev/index title="Home page" password="The secret from hashi vault" 

$ vault kv get secrets/my-app/dev/database 


$ oc create secret generic vault-agent-template-web-pages --from-file=index.html.ctmpl=./index.html --from-file=contact.html.ctmpl=./contact.html \
     --dry-run=client > vault-agent-template-web-pages.yaml


$ vault policy write my-app-secrets - <<EOF
path "secrets/data/my-app/dev/*" {
  capabilities = ["read" , "list"]
}
EOF


$ vault write auth/kubernetes/role/my-app \
    bound_service_account_names=nodejs-demo-hashi,hello-world-app \
    bound_service_account_namespaces=nodejs-demo,hello-world \
    policies=my-app-secrets \
    ttl=24h




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


$ export JWT_TOKEN=$(oc get secret vault-token-x6hrv -n hashicorp-vault -o jsonpath='{.data.token}' | base64 -d)
$ export KUBE_CA_CRT=$(oc get cm kube-root-ca.crt -n openshift-config -o jsonpath='{.data.ca\.crt}') 
$ export KUBE_HOST=$(oc config view --raw --minify --flatten --output 'jsonpath={.clusters[].cluster.server}')


$ vault write auth/kubernetes/config \
     token_reviewer_jwt="$JWT_TOKEN" \
     kubernetes_host="$KUBE_HOST" \
     kubernetes_ca_cert="$KUBE_CA_CRT" 
     
$ vault read auth/kubernetes/config
