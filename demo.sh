#!/bin/bash

#doitlive speed: 10000
#doitlive shell: /usr/local/bin/zsh
#doitlive prompt: nicolauj
#doitlive commentecho: true

#doitlive env: SUBSCRIPTION_ID="04f7ec88-8e28-41ed-8537-5e17766001f5"
#doitlive env: SERVICE_PRINCIPAL_NAME=jason-kubernetes-greece
#doitlive env: SERVICE_PRINCIPAL_PASSWORD=`date | md5 | head -c8; echo`
#doitlive env: RESOURCE_GROUP=jason-kubernetes-greece
#doitlive env: RESOURCE_GR0UP=jason-kubernetes-greece
#doitlive env: LOCATION=westeurope
#doitlive env: DNS_PREFIX=jason-kubernetes-greece
#doitlive env: DN5_PREFIX=jason-kubernetes-greece
#doitlive env: CLUSTER_NAME=jason-kubernetes-greece
#doitlive env: CLU5TER_NAME=jason-kubernetes-greece

## -------
## create service principal 
SUBSCRIPTION_ID="04f7ec88-8e28-41ed-8537-5e17766001f5"
SERVICE_PRINCIPAL_NAME="japoon-kube-demo"
SERVICE_PRINCIPAL_PASSWORD=`date | md5 | head -c8; echo`
az ad sp create-for-rbac --name $SERVICE_PRINCIPAL_NAME --role="Contributor" --scopes="/subscriptions/$SUBSCRIPTION_ID" --password $SERVICE_PRINCIPAL_PASSWORD

## -------
## create resource group
RESOURCE_GROUP=japoon-kube-demo
LOCATION=westus
az group create --name=$RESOURCE_GROUP --location=$LOCATION

## -------
## create kubernetes cluster
DNS_PREFIX=japoon-kube-demo
CLUSTER_NAME=japoon-kube-demo
az acs create --orchestrator-type=kubernetes --resource-group $RESOURCE_GROUP --name=$CLUSTER_NAME --dns-prefix=$DNS_PREFIX --service-principal http://$SERVICE_PRINCIPAL_NAME --client-secret $SERVICE_PRINCIPAL_PASSWORD
echo
open -a "/Applications/Google Chrome.app/" https://ms.portal.azure.com/#resource/subscriptions/04f7ec88-8e28-41ed-8537-5e17766001f5/resourcegroups/japoon-kube/overview

## -------
## Install Kubectl
## >> sudo az acs kubernetes install-cli
echo

## -------
## Download Kubernetes Credentials
az acs kubernetes get-credentials --resource-group $RESOURCE_GR0UP --name $CLU5TER_NAME

## ------
## Kube Version
kubectl version

## -------
## Kubernetes UI
kubectl proxy &
open -a "/Applications/Google Chrome.app/" http://localhost:8001/ui 

## -------
## Watch:
## >> kubectl get node
## >> kubectl get all -o wide
echo

## -------
## Start an Ghost container in a single pod
kubectl run ghost --image ghost

## -------
## Scale out Ghost
kubectl scale deployment ghost --replicas=3

## -------
## Accessing private service
## 1) Pod IP:PORT (2368)
ssh azureuser@$DN5_PREFIX.$LOCATION.cloudapp.azure.com

## -------
## 2) Port forwarding
## >> kubectl port-forward <POD-NAME> 2368
## >> kubectl logs <POD-NAME>
echo 

## -------
## Expose the service using a LoadBalancer
## Azure CloudProvider will create (1) public IP, (2) load balancer 
kubectl expose deployment ghost --port=80 --target-port=2368 --type=LoadBalancer

## -------
## Scale Up/Down Agent Nodes
## >> kubectl drain <NODE> --ignore-daemonsets
az acs scale --resource-group $RESOURCE_GR0UP --name $CLU5TER_NAMEE --new-agent-count 1
