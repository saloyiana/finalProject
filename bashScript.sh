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

echo -e "\n${info}SockShop${reset}"

ip=$(curl http://checkip.amazonaws.com)

G_PORT=$(kubectl get --namespace monitoring -o jsonpath="{.spec.ports[0].nodePort}" services grafana)
K_PORT=(kubectl get --namespace logging -o jsonpath="{.spec.ports[0].nodePort}" services kibana-kibana)
T_PROT=(kubectl get --namespace test -o jsonpath="{.spec.ports[0].nodePort}" services front-end)
P_PORT=(kubectl get --namespace prod -o jsonpath="{.spec.ports[0].nodePort}" services front-end)

echo -e "\n${info}The link to Sock Shop${reset}"
http://$ip:T_PORT
http://$ip:P_PORT


echo -e "\n${info}The link to Kibana Dashboard${reset}"
http://$ip:K_PORT

echo -e "${info}The link to Grafana${reset}"
http://$ip:G_PORT

