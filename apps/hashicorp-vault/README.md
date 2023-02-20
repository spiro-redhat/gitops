Install the Hashicorp vault repo via GitOps. We are going to be using the `Namespace` called `hashicorp-vault`. Once that is installed you may install Vault via the OCP Dev Console. Be sure to enable Dev mode for non-prod ease of getting started.  Check that both the Vault and the Agent pods have started with `oc get po -n hashicorp-vault` 


```
apiVersion: helm.openshift.io/v1beta1
kind: HelmChartRepository
metadata:
  name: hashicorp
spec:
 # optional name that might be used by console
  name: HashiCorp Helm Charts
  connectionConfig:
    url: https://helm.releases.hashicorp.com
```


Setting up Kube Auth 
```
SA_NAME=vault-auth 
SECRET_NAME=vault-auth-token-982vn 
TOKEN_REVIEW_JWT=$(oc get secret -n hashicorp-vault $SECRET_NAME -o jsonpath '{.data.token}' | base64 --decode)
KUBE_CA_CRT=$(oc get secret -n hashicorp-vault $SECRET_NAME -o jsonpath {.data.ca\.crt}' | base64 --decode)
KUBE_HOST=$(oc config view --raw --minify --flatten --output='jsonpath={.clusters[].cluster.server}')

vault write auth/kubernetes/config \
     token_reviewer_jwt="$TOKEN_REVIEW_JWT" \
     kubernetes_host="$KUBE_HOST" \
     kubernetes_ca_cert="$KUBE_CA_CERT" \
     issuer="https://kubernetes.default.svc.cluster.local"
```

Connect to the Vault container

```
oc exec -n hashicorp-vault -it vault-0 -- /bin/sh
```
Enable the kv-v2 secrets engine at a path called `demo` 
```
vault secrets enable -path=demo kv-v2
```
Create a secret path at `demo/my-app/dev/database` 

```
vault kv put demo/my-app/dev/database username="db-username" password="db-password"
```
Verify the secret
```
vault kv get demo/my-app/dev/database
```
Enable the kubernetes authentication method
```
vault auth enable kubernetes
```
Configure the kubernetes authentication method to use the kubernetes API 
```
vault write auth/kubernetes/config \
    kubernetes_host="https://$KUBERNETES_PORT_443_TCP_ADDR:443"

```
Write out the policy named `my-app-secrets` that enables `read` capability for secrets at path `demo/my-app/dev/database`
```
vault policy write my-app-secrets - <<EOF
path "demo/data/my-app/dev/database" {
  capabilities = ["read"]
}
EOF
```

Create a Kubernetes authentication role named `my-app`

```
vault write auth/kubernetes/role/my-app \
    bound_service_account_names=nodejs-demo-hashi \
    bound_service_account_namespaces=nodejs-demo \
    policies=my-app-secrets \
    ttl=24h
```

In your OpenShift deployment add the following annotations: 
```
 annotations:
        vault.hashicorp.com/agent-inject: 'true'
        vault.hashicorp.com/agent-pre-populate-only: 'false'
        vault.hashicorp.com/role: 'my-app'
        vault.hashicorp.com/tls-skip-verify: 'true'
        vault.hashicorp.com/agent-inject-secret-database: 'demo/my-app/dev/database'
        # Environment variable export template
        vault.hashicorp.com/agent-inject-template-database: |
          {{ with secret "demo/my-app/dev/database" -}}
            export USERNAME="{{ .Data.data.username }}"
            export PASSWORD="{{ .Data.data.password }}"

          {{- end }}

```
Play around and see more annotations here: [https://developer.hashicorp.com/vault/docs/platform/k8s/injector/annotations]
Within the deployment under `spec.containers` add: 
```
  command: ['/bin/sh', '-c']
   args: ['source /vault/secrets/database && <entrypoint script>']
```