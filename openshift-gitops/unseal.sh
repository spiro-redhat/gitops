oc get secret -n sealed-secrets -l sealedsecrets.bitnami.com/sealed-secrets-key -o yaml >/tmp/ss-cert

kubeseal -o yaml --recovery-unseal --recovery-private-key /tmp/ss-cert < repo-1028610631-sealed.yaml \
> repo-1028610631.yaml

rm /tmp/ss-cert
