#!/bin/bash
namespace=kubesphere-logging-system

input_list=$(kubectl get inputs.logging.kubesphere.io -n "${namespace}" -o json)

input_name=($(echo $input_list | jq -r '.items[].metadata.name | @json'))


input_size=${#input_name[*]}
echo "$input_size"

for((i=0;i<${input_size};i++));do
echo "${input_name[i]}"
  input_temp=$(echo ${input_name[i]} | sed 's/"//g')
  echo "$input_temp"
   kubectl delete input $input_temp -n ${namespace}
done
