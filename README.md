When ArgoCD is installed in OpenShift GitOps 
```
oc adm policy add-cluster-role-to-user cluster-admin system:serviceaccount:openshift-gitops:openshift-gitops-argocd-application-controller
```


When a namespace will not delete. 

1) Export the Namespace to an env var: 

```
export NAMESPACE=problem-namespace 
````

2) check to see if it is stuck on a finalizer to finish 
 
```
 $ kubectl get namespace ${NAMESPACE} -o yaml
```
