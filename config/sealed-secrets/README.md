Sealed Secrets from Bitnami is predicated on the problem being able to securely store secrets in public repositories without exposing their contents (`Secrets` in Kubernetes are base64 encoded strings and are not secure).

`SealedSecrets` encrypts `Secrets` that are safe to store anywhere, including public repositories. The `SealedSecret` can be decrypted only by the controller running in the target cluster and nobody else  is able to obtain the `Secret` from the `SealedSecret`.

![](img/sealed-secret-components.png?raw=true "The SealedSecret controller generates the assymetric key pair for encryption and decryption") 

Two components make up the `SealedSecret` controller. 
* `kubeseal` - a cli tool that must be installed locally. The `kubeseal` command encrypts `Secrets` that only the sealed secret controller can decerypt. 
* sealed secret controller - deployed to OpenShift. On first deployment the controller will generate a Certificate and Private Key. 

The `kubseal` client for Linux can be downloaded and installed by runnung the code below: 

```bash 
wget https://github.com/bitnami-labs/sealed-secrets/releases/download/<release-tag>/kubeseal-<version>-linux-amd64.tar.gz
tar -xvzf kubeseal-<version>-linux-amd64.tar.gz kubeseal
sudo install -m 755 kubeseal /usr/local/bin/kubeseal
```
Where `release-tag` is the version of the kubeseal release you want to use. For example: `v0.18.0`.
https://github.com/bitnami-labs/sealed-secrets/tags

The Certificate is used to seal a kubernetes `Secret` into a `SealedSecret`. It can be public. 

The Key must always be kept secure; It decrypts the `SealedSecret` into a regular Kubernetes `Secret`. The `Secret` is managed by the `SealedSecret`. If you need to change the `Secret`, simply update the `SealedSecret` and the change propogates to the `Secret`. You can think of the relationship between a `SealedSecret` and a `Secret` in similar terms as the relationship between a `Deployment` and a `Pod`.  

The Certificate can be viewed via the logs when the sealed-secrets-controller is first deployed by issuing the following command: 

```bash 
oc logs --tail=-1 -f  -l name=sealed-secrets-controller -n sealed-secrets 
``` 

You can retrieve the Certificate and Private Key that the sealed-secret-controller uses too: 

```bash
oc get secrets sealed-secret-<id> -n sealed-secrets -o yaml 
```




​![](img/sealed-secret-flow.png?raw=true "Title") 

When a `SealedSecret` is applied, the controller detects it and attempts to decrypt it into a `Secret` that apps can use. 




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
`kubeseal` is used to encrypt this `Secret` into `SealedSecret`. `kubeseal` will require access to the Certificate for this. It can access it via online or from a stored file. 

Online mode: 

```bash 
kubeseal --controller-namespace sealed-secrets < secret.yaml -o yaml > sealed-secret.yaml 
```
A snippet: 

```bash
echo -n bar | oc create secret generic mysecret --dry-run=client --from-file=/dev/stdin -o yaml | kubeseal --controller-namespace sealed-secrets -o yaml  > sealed-secret.yaml
```

From stored file: 

Extract the Certificate from the sealed secret controller and keep it somewhere local. 
This is a good way to manage your secrets if access to the environment is managed through GitOps. If you do not have user access, you can deploy and `Secrets` are encrypted. 


```bash 
kubseal --controller-namespace sealed-secrets \
	--controller-name selead-secrets-controller \  
	--fetch-cert > cert.pem  
```

Next we seal our `Secret` to create a `SealedSecret` 
 
 [ 	DO COLLAPSE SECTION THAT SHOWS HOW TO DEBUG ]

```bash  
kubseal < secret.yaml \
	--cert cert.pem \
	-o yaml > sealed-secret.yaml 
```
Send the SealedSecret to the server. 
```bash
oc create -f sealed-secret.yaml  
```

Check if the `Secret` has been created: 
```bash
oc get secrets 
```
The `Secret` is now managed via the `SealedSecret`. If we need to change the `Secret` we must update the `SealedSecret`. The sealed-secrets-controller will update our `Secret` as well. 




Permissions 



```bash
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

![](img/sealed-secret-architecture.png?raw=true "Title") 

​The components that are deployed with the sealed-secrets-controller. 
