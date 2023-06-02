#!/bin/bash
namespace=kubesphere-logging-system

input_list=$(kubectl get inputs.logging.kubesphere.io -n "${namespace}" -o json)

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




fluentbit_list=$(kubectl get fluentbits.logging.kubesphere.io -n "${namespace}" -o json)
fluentbit_name=($(echo $fluentbit_list | jq -r '.items[].metadata.name | @json'))
fluentbit_spec=($(echo $fluentbit_list | jq -r '.items[].spec | @json'))
fluentbit_labels=($(echo $fluentbit_list | jq -r '.items[].metadata.labels | @json'))
fluentbit_size=${#fluentbit_name[*]}
echo "fb$fluentbit_size"

for((i=0;i<${fluentbit_size};i++));do
cluster__fluentbit_list[i]="{
\"apiVersion\": \"fluentbit.fluent.io/v1alpha2\",
\"kind\": \"FluentBit\",
\"metadata\": {
\"name\": ${fluentbit_name[i]},
\"labels\": ${fluentbit_labels[i]}
},
\"spec\": ${fluentbit_spec[i]}
}"
done

echo "yunxing"

for((i=0;i<${input_size};i++));do
echo ${cluster_input_list[i]} | kubectl apply -f -
done




                                 
