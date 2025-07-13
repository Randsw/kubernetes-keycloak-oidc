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

# Create manager role (only view)
kubectl apply -f - <<EOF
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: kube-manager
subjects:
- kind: Group
  name: kube-manager
  apiGroup: rbac.authorization.k8s.io
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: view
EOF

# Creating developers role for namespace app
kubectl create ns app

kubectl apply -f - <<EOF
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: kube-admin
  namespace: app
subjects:
- kind: Group
  name: kube-dev
  apiGroup: rbac.authorization.k8s.io
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: view
---
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: kube-dev-lead
  namespace: app
subjects:
- kind: Group
  name: kube-dev-lead
  apiGroup: rbac.authorization.k8s.io
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: edit
EOF