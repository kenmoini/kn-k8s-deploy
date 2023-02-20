#!/bin/bash

# Install OLM
if [ ! -f /usr/local/bin/operator-sdk ]; then
  echo "Installing operator-sdk"
  export ARCH=$(case $(uname -m) in x86_64) echo -n amd64 ;; aarch64) echo -n arm64 ;; *) echo -n $(uname -m) ;; esac)
  export OS=$(uname | awk '{print tolower($0)}')

  export OPERATOR_SDK_DL_URL=https://github.com/operator-framework/operator-sdk/releases/download/v1.27.0
  curl -LO ${OPERATOR_SDK_DL_URL}/operator-sdk_${OS}_${ARCH}
  chmod +x operator-sdk_${OS}_${ARCH} && sudo mv operator-sdk_${OS}_${ARCH} /usr/local/bin/operator-sdk
fi

# Check for the ns
kubectl get ns olm || operator-sdk olm install

# Allow OLM to do the things - wtf is this shit https://kubernetes.io/blog/2021/12/09/pod-security-admission-beta/
kubectl label --overwrite ns olm pod-security.kubernetes.io/warn=restricted pod-security.kubernetes.io/enforce=baseline

# Install the ArgoCD Operator
kubectl get ns argocd || kubectl create namespace argocd

#kubectl apply -f ~/k8s-secret-rh-reg-pull.yml
#kubectl patch serviceaccount default -p '{"imagePullSecrets": [{"name": "11009103-kemok8s-pull-secret"}]}'

kubectl get catalogsource -n olm argocd-catalog || kubectl create -n olm -f https://raw.githubusercontent.com/argoproj-labs/argocd-operator/master/deploy/catalog_source.yaml
kubectl get operatorgroup -n argocd argocd-operator || kubectl create -n argocd -f https://raw.githubusercontent.com/argoproj-labs/argocd-operator/master/deploy/operator_group.yaml
kubectl get subscription -n argocd argocd-operator || kubectl create -n argocd -f argocd/bootstrap-operator/subscription.yml

# wait for it to deploy 

kubectl get argocd/argocd -n argocd || kubectl apply -n argocd -k argocd/bootstrap-operator/

# old lol

#
#kubectl apply -n argocd -f argocd/bootstrap/argocd-configmap.yml
#
#kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
#
