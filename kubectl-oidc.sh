#!/usr/bin/env bash

set -e

# # helper function
# kubectl_config(){
#   local ISSUER=https://keycloak.kind.cluster/realms/master
#   local ENDPOINT=$ISSUER/protocol/openid-connect/token

#   local ID_TOKEN=$(curl -k -X POST $ENDPOINT \
#     -d grant_type=password \
#     -d client_id=kube \
#     -d client_secret=kube-client-secret \
#     -d username=$1 \
#     -d password=$1 \
#     -d scope=openid \
#     -d response_type=id_token | jq -r '.id_token')
    
#     echo "ID_TOKEN\n"
#     echo $ID_TOKEN

#   local REFRESH_TOKEN=$(curl -k -X POST $ENDPOINT \
#     -d grant_type=password \
#     -d client_id=kube \
#     -d client_secret=kube-client-secret \
#     -d username=$1 \
#     -d password=$1 \
#     -d scope=openid \
#     -d response_type=id_token | jq -r '.refresh_token')

#     echo "REFRESH_TOKEN\n"

#     echo $REFRESH_TOKEN

#     local CA_DATA=$(cat .ssl/root-ca.pem | base64 | tr -d '\n')  

#     echo "CA_DATA\n"
#     echo $CA_DATA
    
#     kubectl config set-credentials $1 \
#     --auth-provider=oidc \
#     --auth-provider-arg=client-id=kube \
#     --auth-provider-arg=client-secret=kube-client-secret \
#     --auth-provider-arg=idp-issuer-url=$ISSUER \
#     --auth-provider-arg=id-token=$ID_TOKEN \
#     --auth-provider-arg=refresh-token=$REFRESH_TOKEN \
#     --auth-provider-arg=idp-certificate-authority-data=$CA_DATA  
    
#     kubectl config set-context $1 --cluster=kind-kind --user=$1
# }
# # setup config for our users
# kubectl_config user-admin
# kubectl_config user-dev

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

kubectl config set-context oidc-client --cluster=kind-kind --user=oidc

kubectl config use-context oidc-client


