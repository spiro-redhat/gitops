# Set VAULT_SA_NAME to the service account you created earlier
`$ export VAULT_SA_NAME=$(oc -n nodejs-demo get sa vault-auth -o jsonpath="{.secrets[*]['name']}")`

# Set SA_JWT_TOKEN value to the service account JWT used to access the TokenReview API
`$ export SA_JWT_TOKEN=$(oc -n nodejs-demo get secret $VAULT_SA_NAME -o jsonpath="{.data.token}" | base64 --decode; echo)`

# Set SA_CA_CRT to the PEM encoded CA cert used to talk to Kubernetes API
`$ export SA_CA_CRT=$(oc  -n nodejs-demo get secret $VAULT_SA_NAME -o jsonpath="{.data['ca\.crt']}" | base64 --decode; echo)`

# OpenShift API endpoint  
`$ export KUBE_HOST=$(oc config view --raw --minify --flatten --output='jsonpath={.clusters[].cluster.server}')`

```
vault write auth/kubernetes/config \
     token_reviewer_jwt="$SA_JWT_TOKEN" \
     kubernetes_host="$KUBE_HOST" \
     kubernetes_ca_cert="$SA_CA_CERT" \
     issuer="https://kubernetes.default.svc.cluster.local"
```