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
(oc proxy &
oc get namespace $NAMESPACE -o json |jq '.spec = {"finalizers":[]}' >temp.json
curl -k -H "Content-Type: application/json" -X PUT --data-binary @temp.json 127.0.0.1:8001/api/v1/namespaces/$NAMESPACE/finalize
)
``` 
kill the proxy 
```
jobs 
kill %N
```
Where N=background task number 

