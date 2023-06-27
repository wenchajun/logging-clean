#!/bin/bash
namespace=kubesphere-logging-system

function converting(){
## Converting an existing configuration to a new one
local resource=$1
local kind=$2
local list=$(kubectl get  $resource.logging.kubesphere.io -A -o json)
local name=($(echo $list | jq -r '.items[].metadata.name | @json'))
local labels=($(echo $list | jq -r '.items[].metadata.labels | @json'))
local spec=($(echo $list | jq -r '.items[].spec | @json'))
local size=${#spec[*]}
echo "Number of original $resource configuration files:$size"
for((i=0;i<${size};i++));do
cluster_resource_list[i]="{
\"apiVersion\": \"fluentbit.fluent.io/v1alpha2\",
\"kind\": \"${kind}\",
\"metadata\": {
\"name\": ${name[i]},
\"labels\": ${labels[i]}
},
\"spec\": ${spec[i]}
}"
done

for((i=0;i<${size};i++));do
echo ${cluster_resource_list[i]} | kubectl apply -f -
done
## Uninstall the fluentbit-operator and the original configuration
for((i=0;i<${size};i++));do
echo "${name[i]}"
  temp=$(echo ${name[i]} | sed 's/"//g')
  echo "$temp"
   kubectl delete  $resource.logging.kubesphere.io $temp -n ${namespace}
done
}

converting "inputs" "ClusterInput"
converting "parsers" "ClusterParser"
converting "filters" "ClusterFilter"
converting "outputs" "ClusterOutput"
converting "fluentbitconfigs" "ClusterFluentBitConfig"

fluentbit_list=$(kubectl get fluentbits.logging.kubesphere.io -A -o json)
fluentbit_name=($(echo $fluentbit_list | jq -r '.items[].metadata.name'))
fluentbit_spec=($(echo $fluentbit_list | jq -r '.items[].spec | @json'))
fluentbit_labels=($(echo $fluentbit_list | jq -r '.items[].metadata.labels | @json'))
fluentbit_size=${#fluentbit_name[*]}
echo "Number of original fluentbit configuration files:$fluentbit_size"

for((i=0;i<${fluentbit_size};i++));do
cluster__fluentbit_list[i]="{
\"apiVersion\": \"fluentbit.fluent.io/v1alpha2\",
\"kind\": \"FluentBit\",
\"metadata\": {
\"name\":  \"fluent-operator-${fluentbit_name[i]}\",
\"labels\": ${fluentbit_labels[i]},
\"namespace\": \"${namespace}\"
},
\"spec\": ${fluentbit_spec[i]}
}"
done

for((i=0;i<${fluentbit_size};i++));do
echo ${cluster__fluentbit_list[i]} | kubectl apply -f -
done

# Determine if Deployment exists
if kubectl get deployment -n $namespace $deployment >/dev/null 2>&1; then
    # Delete Deployment if it exists
    kubectl delete deployment -n $namespace $deployment
    kubectl delete clusterrolebinding kubesphere:operator:fluentbit-operator
    kubectl delete clusterrole kubesphere:operator:fluentbit-operator
    kubectl delete serviceaccount fluentbit-operator -n $namespace
    echo "Deployment $deployment deleted"
else
    # If it does not exist, output the message
    echo "Deployment $deployment does not exist"
fi

## Delete the old crd
kubectl get crd -o=jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}' | grep "logging.kubesphere.io" | xargs -I crd_name kubectl delete crd crd_name
