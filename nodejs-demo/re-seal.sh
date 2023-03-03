#! /bin/bash 
kubeseal --controller-namespace=sealed-secrets -n nodejs-demo < secret.txt > sealed-secret.yaml

