#!/usr/bin/env bash

set -e

helm upgrade --install --wait --timeout 35m --atomic --namespace keycloak --create-namespace \
  keycloak oci://registry-1.docker.io/bitnamicharts/keycloak --values - <<EOF
auth:
  adminUser: admin
  adminPassword: admin
ingress:
  enabled: true
  ingressClassName: nginx
  hostname: keycloak.kind.cluster
  annotations:
    cert-manager.io/cluster-issuer: ca-issuer
  tls: true
postgresql:
  enabled: true
  postgresqlPassword: password
EOF
#   extraTls:
#   - hosts:
#     - keycloak.kind.cluster
#       secretName: keycloak.kind.cluster-tls

kubectl apply -f - <<EOF
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: kube-admin
subjects:
- kind: Group
  name: kube-admin
  apiGroup: rbac.authorization.k8s.io
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
---
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: kube-dev
subjects:
- kind: Group
  name: kube-dev
  apiGroup: rbac.authorization.k8s.io
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: edit
EOF