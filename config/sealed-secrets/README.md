To view public certificate for encrypting: 

oc logs --tail=-1 -f -l name=sealed-secrets-controller -n sealed-secrets

# Get the id of the secret 
oc get secrets -n sealed-secrets | grep kubernetes.io/tls 

# To view key and certificate 
oc get secret sealed-secret-<id> -n sealed-secrets -o yaml 
