#!/usr/bin/env bash

set -e

CA_DATA=$(cat .ssl/root-ca.pem | base64 | tr -d '\n')  

kubectl config set-credentials oidc-client \
  --exec-interactive-mode=Never \
  --exec-api-version=client.authentication.k8s.io/v1 \
  --exec-command=kubectl \
  --exec-arg=oidc-login \
  --exec-arg=get-token \
  --exec-arg=--oidc-issuer-url=https://keycloak.kind.cluster/realms/master \
  --exec-arg=--oidc-client-id=kube \
  --exec-arg=--oidc-client-secret=kube-client-secret \
  --exec-arg=--certificate-authority-data=$CA_DATA

kubectl config set-context oidc-client --cluster=kind-kind --user=oidc-client

kubectl config use-context oidc-client


