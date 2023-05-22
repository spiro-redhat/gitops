# https://docs.openshift.com/container-platform/4.13/security/compliance_operator/compliance-operator-raw-results.html


```
oc get compliancesuites nist-moderate-modified \
-o json -n openshift-compliance | jq '.status.scanStatuses[].resultsStorage'
```

```
 oc get pvc -n openshift-compliance rhcos4-moderate-worker
```


```
oc cp pv-extract:/workers-scan-results -n openshift-compliance .
```