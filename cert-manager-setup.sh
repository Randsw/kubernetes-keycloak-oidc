#!/usr/bin/env bash

set -e

kubectl create namespace cert-manager --dry-run=client -o yaml | kubectl apply -f - >/dev/null

# Create CA secret
kubectl create secret tls ca-tls-secret \
  --cert=.ssl/root-ca.pem \
  --key=.ssl/root-ca-key.pem \
  -n cert-manager

  # Install cert-manager

helm upgrade --install --wait --timeout 35m --atomic --namespace cert-manager \
  --repo https://charts.jetstack.io cert-manager cert-manager --values - <<EOF
crds:
  enabled: true
EOF

cat << EOF | kubectl apply -f -
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: ca-issuer
  namespace: cert-manager
spec:
  ca:
    secretName: ca-tls-secret
EOF