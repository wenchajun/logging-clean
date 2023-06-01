!/bin/bash
namespace=kubesphere-logging-system
deployment="fluentbit-operator"


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



parser_list=$(kubectl get parsers.logging.kubesphere.io -n "${namespace}" -o json)

parser_name=($(echo $input_list | jq -r '.items[].metadata.name | @json'))


parser_size=${#parser_name[*]}
echo "paeser_size$parser_size"

for((i=0;i<${parser_size};i++));do
echo "${parser_name[i]}"
  parser_temp=$(echo ${parser_name[i]} | sed 's/"//g')
  echo "parser$parser_temp"
   kubectl delete parser $parser_temp -n ${namespace}
done

filter_list=$(kubectl get filters.logging.kubesphere.io -n "${namespace}" -o json)

filter_name=($(echo $input_list | jq -r '.items[].metadata.name | @json'))


filter_size=${#filter_name[*]}
echo "filter$filter_size"

for((i=0;i<${filter_size};i++));do
echo "${filter_name[i]}"
  filter_temp=$(echo ${filter_name[i]} | sed 's/"//g')
  echo "$filter_temp"
   kubectl delete filter $filter_temp -n ${namespace}
done
output_list=$(kubectl get  outputs.logging.kubesphere.io -n "${namespace}" -o json)

output_name=($(echo $output_list | jq -r '.items[].metadata.name | @json'))


output_size=${#output_name[*]}
echo "$output_size"

for((i=0;i<${output_size};i++));do
echo "${output_name[i]}"
  output_temp=$(echo ${output_name[i]} | sed 's/"//g')
  echo "$output_temp"
   kubectl delete output $output_temp -n ${namespace}
done

fluentbit_config__list=$(kubectl get  fluentbitconfigs.logging.kubesphere.io -n "${namespace}" -o json)

fluentbit_config_name=($(echo $fluentbit_config__list | jq -r '.items[].metadata.name | @json'))


fluentbit_config_size=${#fluentbit_config_name[*]}
echo "fbconfigsize$fluentbit_config_size"

for((i=0;i<${fluentbit_config_size};i++));do
echo "${fluentbit_config_name[i]}"
  fluentbit_config_temp=$(echo ${fluentbit_config_name[i]} | sed 's/"//g')
  echo "$fluentbit_config_temp"
   kubectl delete fluentbitconfig $fluentbit_config_temp -n ${namespace}
done


fluentbit=$(kubectl get fluentbits.logging.kubesphere.io -n "${namespace}" -o json)
fluentbit_name=($(echo $fluentbit | jq -r '.items[].metadata.name | @json'))
fluentbit_size=${#fluentbit_name[*]}
echo "fb$fluentbit_size"

for((i=0;i<${fluentbit_size};i++));do
echo "${fluentbit_name[i]}"
  fluentbit_temp=$(echo ${fluentbit_name[i]} | sed 's/"//g')
  echo "$fluentbit_temp"
   kubectl delete fluentbit $fluentbit_temp -n ${namespace}
done
# 判断 Deployment 是否存在
if kubectl get deployment -n $namespace $deployment >/dev/null 2>&1; then
    # 如果存在，则删除 Deployment
    kubectl delete deployment -n $namespace $deployment
    echo "Deployment $deployment 已删除"
else
    # 如果不存在，则输出提示信息
    echo "Deployment $deployment 不存在"
fi

kubectl get crd -o=jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}' | grep "logging.kubesphere.io" | xargs -I crd_name kubectl delete crd crd_name
