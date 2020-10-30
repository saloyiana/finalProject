 #!/bin/bash
# The world isn't black and white
export reset='\033[0m'
export black='\033[0;30m'
export red='\033[0;31m'
export green='\033[0;32m'
export yellow='\033[0;33m'
export blue='\033[0;34m'
export purple='\033[0;35m'
export cyan='\033[0;36m'
export white='\033[0;37m'
export info=$cyan
echo -e "\n${info}WeaveSocks${reset}"
echo -e "\n${info}-----------${reset}"
curl http://checkip.amazonaws.com
echo -e "\n${info}Grafana Port${blue}"
echo -e "\n${info}------------${blue}"
kubectl get --namespace monitoring -o jsonpath="{.spec.ports[0].nodePort}" services grafana
echo -e "\n${info}Kibana Port${green}"
echo -e "\n${info}-----------${green}"
kubectl get --namespace logging -o jsonpath="{.spec.ports[0].nodePort}" services kibana-kibana
echo -e "\n${info}Platform Port${yellow}"
echo -e "\n${info}-----------${yellow}"
kubectl get --namespace test -o jsonpath="{.spec.ports[0].nodePort}" services front-end
echo -e "\n${info}-----------${yellow}"
kubectl get --namespace prod -o jsonpath="{.spec.ports[0].nodePort}" services front-end
