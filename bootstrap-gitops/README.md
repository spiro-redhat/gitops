# openshift-gitops
This directory contains the initial configuration to bootstrap gitops. Additional config is whithin ./apps/openshift-gitops. This configuration should be used to modify the config of gitops. 

Allow GitOps service account permissions to do stuff
```
 oc adm policy add-cluster-role-to-user cluster-admin system:serviceaccount:openshift-gitops:openshift-gitops-argocd-application-controller
```

```
oc edit argocd openshift-gitops -n openshift-gitops 
```

```
rbac:
    policy: | 
      g, system:cluster-admins, role:admin
      g, cluster-admins, role:admin
      g, argo-admins, role:admin
    scopes: '[groups]'
```