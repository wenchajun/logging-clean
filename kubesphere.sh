#!/bin/bash
namespace=kubesphere-logging-system

## Converting an existing configuration to a new one

input_list=$(kubectl get inputs.logging.kubesphere.io -n "${namespace}" -o json)
input_name=($(echo $input_list | jq -r '.items[].metadata.name | @json'))
input_labels=($(echo $input_list | jq -r '.items[].metadata.labels | @json'))
input_spec=($(echo $input_list | jq -r '.items[].spec | @json'))
input_size=${#input_spec[*]}
echo "Number of original input configuration files:$input_size"

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


parser_list=$(kubectl get parsers.logging.kubesphere.io -n "${namespace}" -o json)
parser_name=($(echo $parser_list | jq -r '.items[].metadata.name | @json'))
parser_labels=($(echo $parser_list | jq -r '.items[].metadata.labels | @json'))
parser_spec=($(echo $parser_list | jq -r '.items[].spec | @json'))
parser_size=${#parser_spec[*]}
echo "Number of original parser configuration files:$parser_size"

for((i=0;i<${parser_size};i++));do
cluster_parser_list[i]="{
\"apiVersion\": \"fluentbit.fluent.io/v1alpha2\",
\"kind\": \"ClusterParser\",
\"metadata\": {
\"name\": ${parser_name[i]},
\"labels\": ${parser_labels[i]}
},
\"spec\": ${parser_spec[i]}
}"
done


filter_list=$(kubectl get filters.logging.kubesphere.io -n "${namespace}"  -o json)
filter_name=($(echo $filter_list | jq -r '.items[].metadata.name | @json'))
filter_labels=($(echo $filter_list | jq -r '.items[].metadata.labels | @json'))
filter_spec=($(echo $filter_list | jq -r '.items[].spec | @json'))
filter_size=${#filter_spec[*]}
echo "Number of original filter configuration files:$filter_size"

for((i=0;i<${filter_size};i++));do
cluster_filter_list[i]="{
\"apiVersion\": \"fluentbit.fluent.io/v1alpha2\",
\"kind\": \"ClusterFilter\",
\"metadata\": {
\"name\": ${filter_name[i]},
\"labels\": ${filter_labels[i]}
},
\"spec\": ${filter_spec[i]}
}"
done


output_list=$(kubectl get outputs.logging.kubesphere.io -n "${namespace}" -o json)
output_name=($(echo $output_list | jq -r '.items[].metadata.name | @json'))
output_labels=($(echo $output_list | jq -r '.items[].metadata.labels | @json'))
output_spec=($(echo $output_list | jq -r '.items[].spec | @json'))
output_size=${#output_spec[*]}
echo "Number of original output configuration files:$output_size"

for((i=0;i<${output_size};i++));do
cluster_output_list[i]="{
\"apiVersion\": \"fluentbit.fluent.io/v1alpha2\",
\"kind\": \"ClusterOutput\",
\"metadata\": {
\"name\": ${output_name[i]},
\"labels\": ${output_labels[i]}
},
\"spec\": ${output_spec[i]}
}"
done


fluentbit_config_list=$(kubectl get  fluentbitconfigs.logging.kubesphere.io -n "${namespace}" -o json)
fluentbit_config_name=($(echo $fluentbit_config_list | jq -r '.items[].metadata.name | @json'))
fluentbit_config_spec=($(echo $fluentbit_config_list | jq -r '.items[].spec | @json'))
fluentbit_config_labels=($(echo $fluentbit_config_list | jq -r '.items[].metadata.labels | @json'))
fluentbit_config_size=${#fluentbit_config_spec[*]}
echo "Number of original fluentbit_config configuration files:$fluentbit_config_size"

for((i=0;i<${fluentbit_config_size};i++));do
cluster_fluentbit_config_list[i]="{
\"apiVersion\": \"fluentbit.fluent.io/v1alpha2\",
\"kind\": \"ClusterFluentBitConfig\",
\"metadata\": {
\"name\": ${fluentbit_config_name[i]},
\"labels\": ${fluentbit_config_labels[i]}
},
\"spec\": ${fluentbit_config_spec[i]}
}"
done

fluentbit_list=$(kubectl get fluentbits.logging.kubesphere.io -n "${namespace}" -o json)
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

for((i=0;i<${fluentbit_config_size};i++));do
echo ${cluster_fluentbit_config_list[i]} | kubectl apply -f -
done

for((i=0;i<${input_size};i++));do
echo ${cluster_input_list[i]} | kubectl apply -f -
done

for((i=0;i<${parser_size};i++));do
echo ${cluster_parser_list[i]} | kubectl apply -f -
done

for((i=0;i<${filter_size};i++));do
echo ${cluster_filter_list[i]} | kubectl apply -f -
done

for((i=0;i<${output_size};i++));do
echo ${cluster_output_list[i]} | kubectl apply -f -
done

## Uninstall the fluentbit-operator and the original configuration

for((i=0;i<${input_size};i++));do
echo "${input_name[i]}"
  input_temp=$(echo ${input_name[i]} | sed 's/"//g')
  echo "$input_temp"
   kubectl delete input $input_temp -n ${namespace}
done

for((i=0;i<${parser_size};i++));do
echo "${parser_name[i]}"
  parser_temp=$(echo ${parser_name[i]} | sed 's/"//g')
  echo "parser$parser_temp"
   kubectl delete parser $parser_temp -n ${namespace}
done

for((i=0;i<${filter_size};i++));do
echo "${filter_name[i]}"
  filter_temp=$(echo ${filter_name[i]} | sed 's/"//g')
  echo "$filter_temp"
   kubectl delete filter $filter_temp -n ${namespace}
done

for((i=0;i<${output_size};i++));do
echo "${output_name[i]}"
  output_temp=$(echo ${output_name[i]} | sed 's/"//g')
  echo "$output_temp"
   kubectl delete output $output_temp -n ${namespace}
done

for((i=0;i<${fluentbit_config_size};i++));do
echo "${fluentbit_config_name[i]}"
  fluentbit_config_temp=$(echo ${fluentbit_config_name[i]} | sed 's/"//g')
  echo "$fluentbit_config_temp"
   kubectl delete fluentbitconfig $fluentbit_config_temp -n ${namespace}
done

for((i=0;i<${fluentbit_size};i++));do
echo "${fluentbit_name[i]}"
  fluentbit_temp=$(echo ${fluentbit_name[i]} | sed 's/"//g')
  echo "$fluentbit_temp"
   kubectl delete fluentbit $fluentbit_temp -n ${namespace}
done

# Determine if Deployment exists
if kubectl get deployment -n $namespace $deployment >/dev/null 2>&1; then
    # Delete Deployment if it exists
    kubectl delete deployment -n $namespace $deployment
    echo "Deployment $deployment deleted"
else
    # If it does not exist, output the message
    echo "Deployment $deployment does not exist"
fi

## Delete the old crd
kubectl get crd -o=jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}' | grep "logging.kubesphere.io" | xargs -I crd_name kubectl delete crd crd_name
