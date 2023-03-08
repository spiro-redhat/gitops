 
 ```
 htpasswd -c -B -b </path/to/users.htpasswd> <user_name> <password>
 ```


 ```
 oc create secret generic my-htpasswd-secret --from-file=htpasswd=</path/to/users.htpasswd> -n openshift-config --dry-run=client -o yaml > users.secret.htpasswd 
 ```

 ```
 kubeseal --controller-namespace selead-secrets -n openshift-config < ./users.secret.htpasswd > ./users.sealed-secret.htpasswd 
 ```

 ```

 ```