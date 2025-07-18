#!/usr/bin/env bash

set -e

helm upgrade --install --wait --timeout 35m --atomic --namespace headlamp --create-namespace \
  --repo https://kubernetes-sigs.github.io/headlamp/ headlamp headlamp --values - <<EOF
config: 
  oidc:
    clientID: kube
    clientSecret: kube-client-secret
    issuerURL: "https://keycloak.kind.cluster/realms/master"
    scopes: "email,groups"
  extraArgs:
  - -insecure-ssl
ingress:
  enabled: true
  ingressClassName: nginx
  hostname: keycloak.kind.cluster
  annotations:
    cert-manager.io/cluster-issuer: ca-issuer
  hosts:  
    - host: console.kind.cluster
      paths:
      - path: /
        type: ImplementationSpecific
  tls:   
    - secretName: console.kind.cluster-tls
      hosts:
        - console.kind.cluster
EOF
