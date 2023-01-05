Sealed Secrets from Bitnami is predicated on the problem being able to securely store secrets in public repositories without exposing their contents (`Secrets` in Kubernetes are base64 encoded strings and are not secure).

`SealedSecrets` encrypts `Secrets` which is safe to store anywhere, including public repositories. The `SealedSecret` can be decrypted only by the controller running in the target cluster and nobody else (not even the original author) is able to obtain the `Secret` from the `SealedSecret`.

![](img/sealed-secret-architecture.png?raw=true "Title") 
![](img/sealed-secret-components.png?raw=true "Title") 
![](img/sealed-secret-flow.png?raw=true "Title") 



To create a `SealedSecret` ,first create a regular `Secret` (name the file secret.yaml): 

```yaml 
---
apiVersion: v1 
kind: Secret
metadata:
  name: creds
type: Opaque
data: 
  token: VEhFLVNFQ1JFVC1UT0tFTi1JUy1NRS1NV0hBSEFIQUhBSA==
```

You will need to extract the public key from the sealed secret controller 

```bash 
kubseal --controller-namespace sealed-secrets \
	--controller-name selead-secrets-controller \  
	--fetch-cert > cert.pem  
```

Next we seal our `Secret` to create a `SealedSecret` 

```bash  
kubseal < secret.yaml \
	--cert cert.pem \
	--scope strict \
	-o yaml > sealed-secret.yaml 
  

# Other options include: 
# --scope strict           Enforces the sealed secret to have the same name and namespace as the child object, the secret. This is the default behaviour.
# --scope namespace-wide   Change the name but keep the namespace  
# --scope cluster-wide     Change the name or the namespace 


# remove the original secret and keep it out of source control 
rm secret.yaml 
```

Sometimes you need to decrypt the `Secret` yourself on the CLI. If this is the case, try this: 

```bash
oc get secret -n sealed-secrets -l sealedsecrets.bitnami.com/sealed-secrets-key -o yaml >/tmp/ss-cert

kubeseal --recovery-unseal --recovery-private-key /tmp/ss-cert < config-bundle-secret.yaml \
| jq -r '.data."config.yaml"' | base64 --decode > config.yaml

rm /tmp/ss-cert 
``` 

Backing up and restoring your keys

The private key is stored as a `Secret` owned by the sealed-secrets-controller. There are no backdoors, without the private key you cannot decrypt to the `SealedSecrets`. If you cannot get to the `SealedSecret` with the private key and if you are unable to access the `Secrets` within the cluster, then you will need to generate new keys for everything and seal them with a new certificate key pair.

The backup: 
```bash 
oc get secret -n sealed-secrets sealed-secrets-key<ID> -o yaml >sealed-secret-keep-me-omg-safe.key
``` 
To restore from a backup after some disaster, just put that secret back before starting the controller - or if the controller was already started, replace the newly-created `Secret` and restart the controller:

```bash 
# edit the backup key and switch the name to reflect the new name of the key 
oc delete secret -n sealed-secrets sealed-secrets-key<ID> 
oc create secret -n sealed-secrets -f sealed-secret-keep-me-omg-safe.key 
oc delete pod -n sealed-secrets -l name=sealed-secrets-controller
# the old key with the name of the new key should be installed and operational. 
# existing sealed secrets can now be used 
```