# openshift-gitops
This directory contains the initial configuration to bootstrap gitops. Additional config is whithin ./apps/openshift-gitops. This configuration should be used to modify the config of gitops. 


```
oc edit argocd openshift-gitops -n openshift-gitops 
```
```
rbac:
    policy: 'g, argo-admins role:my-project-admin'
    scopes: '[groups]'
```