# openshift-gitops
This directory contains the configuration for the `openshift-gitops` namespace, which contains the `openshift-gitops` operator. 

## appset.yaml
The most notable file in this direcotry is `appset.yaml`, which contains our main ApplicationSet. 

An ApplicationSet is used to configure ArgoCD so that it knows where to look. See the documentation 
[here](https://argo-cd.readthedocs.io/en/stable/user-guide/application-set/).

Our `appset` points to this git repository and tells it to create a new `Application` for every directory in `gitops-config`, 
as well as a new namespace/project.


##  repo-1028610631-sealed.yaml

The file `repo-1028610631-sealed.yaml` contains the git credentials for ArgoCD to log into Github and access this git repository.
Because these credentials are sensitive, they are encrypted with an operator called `sealed-secrets`.
Only Openshift has the key to encrypt and decrypt the encrypted data in a `SealedSecret`.
Read more about it in the `sealed-secrets/` directory, which contains the installation and configuration for the `sealed-secrets` operator.


## `seal.sh` and `unseal.sh`

`seal.sh` and `unseal.sh` are shell scripts that you can run to decrypt the SealedSecrets in this directory.
You can then make changes to the unencrypted secrets and reseal them to update their state in Openshift.

You will need kubeseal installed and on your path to run these scripts. 
kInstall the tool from [here](https://github.com/bitnami-labs/sealed-secrets/releases).

Make sure you have logged into the openshift client in your terminal before running the scripts.
The scripts connect to the Openshift cluster to encrypt and decrypt the secrets.

The scripts must be run with this `openshift-gitops/` directory as your working directory.

## argocd-ssh-known-hosts-cm.yaml

This configmap contains SSH host keys so that we can verify SSH connections to git repositories. 
Most of these were included with openshift-gitops, but some more host keys for github.com were added.

## The chicken and the egg (How openshift-gitops was bootstrapped)
While some of the configuration for openshift-gitops is stored in this directory so that it can easily be changed,
obviously openshift-gitops cannot manage the cluster before it is installed.

openshift-gitops was installed through the Operator Hub in the Openshift console.
The `repo-1028610631` secret containing the deploy key needed to read the private github repository was created through the ArgoCD console, 
and the extra SSH host keys needed to connect to Github were also added through the ArgoCD console. 
Then, the ApplicationSet `appset` was manually applied through the Openshift Console to connect the github repository and activate gitops synchronization.

Finally, the command `oc adm policy add-cluster-role-to-user cluster-admin system:serviceaccount:openshift-gitops:openshift-gitops-argocd-application-controller`
was run to grant the openshift-gitops admin access to every namespace on the Openshift cluster. 
By default, openshift-gitops does not have full cluster-wide access for security reasons, 
and [access must be granted on a per-namespace basis](https://access.redhat.com/solutions/6331341).
However, this is kind of clunky for a lab environment with rapid iteration, 
so we just granted the openshift-gitops operator admin access to all namespaces.
