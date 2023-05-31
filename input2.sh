#!/bin/bash

input_list=$(kubectl get inputs.logging.kubesphere.io -n kubesphere-logging-system -o json)

input_name=($(echo $input_list | jq -r '.items[].metadata.name | @json'))


input_labels=($(echo $input_list | jq -r '.items[].metadata.labels | @json'))
input_spec=($(echo $input_list | jq -r '.items[].spec | @json'))

##sa=($(echo $spec | jq -r '.[] | @json'))

input_size=${#input_spec[*]}
echo "$input_size"

for((i=0;i<${input_size};i++));do
cluster_input_list[i]="{
\"apiVersion\": \"fluentbit.fluent.io/v1alpha2\",
\"kind\": \"ClusterInput\",
\"metadata\": {
\"name\": ${input_name[i]},
\"labels\": ${input_labels[i]}
},
\"spec\": ${input_spec[i]}
}"
done

for((i=0;i<${input_size};i++));do
echo "${cluster_input_list[i]}"
done



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
