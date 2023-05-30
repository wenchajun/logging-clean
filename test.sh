#!/bin/bash
json=$(kubectl get inputs.logging.kubesphere.io -n kubesphere-logging-system -o json)

name=$(echo $json | jq -r '[.items[].metadata.name]')

## spec=$(echo $json | jq -r '.items[].spec ')

abel=$(echo $json | jq -r '[.items[].metadata.labels]')
spec=$(echo $json | jq -r '[.items[].spec]')

sa=($(echo $spec | jq -r '.[] | @json'))


size=${#sa[*]}
echo "$size"

for((i=0;i<size;i++));do
echo "111${spec[$i]}"
echo "222${name[$i]}"
echo "********$i"
done



##echo "spec${spec[0]}"

##echo "specyaml${spec_yaml}"

##cluster_input=$(cat <<EOF
##apiVersion: fluentbit.fluent.io/v1alpha2
##kind: ClusterInput
##metadata:
##  name:${name[0]}
##  labels:${label[0]}
##spec:
##  ${spec[0]}
##EOF
##)

##echo "name${cluster_input}"
