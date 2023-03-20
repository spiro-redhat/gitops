 
 ```
 htpasswd -c -B -b </path/to/users.htpasswd> <user_name> <password>
 ```


```
oc create secret generic my-htpasswd-secret --from-file=htpasswd=./users.htpasswd -n openshift-config --dry-run=client -o yaml > users.htpasswd-secret.yaml
```

 ```
 kubeseal --controller-namespace sealed-secrets -n openshift-config < ./users.htpasswd-secret.yaml > ./users.htpasswd-sealed-secret.yaml
 ```

 ```

 ```