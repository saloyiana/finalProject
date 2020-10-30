#FIRST STEP:

.PHONY: cluster namespaces tekton cli
up: cluster namespaces tekton cli main elk install-prometheus install-grafana
build: frontend cart-install catalogue-install orders-install payment-install user-install shipping-install queue-master-install 

cluster:
	k3d cluster create sockShop \
	    -p 80:80@loadbalancer \
	    -p 443:443@loadbalancer \
	    -p 30000-32767:30000-32767@server[0] \
	    -v /etc/machine-id:/etc/machine-id:ro \
	    -v /var/log/journal:/var/log/journal:ro \
	    -v /var/run/docker.sock:/var/run/docker.sock \
            --k3s-server-arg '--no-deploy=traefik' \ 
	    --agents 3
cluster-down:
	k3d cluster delete sockShop

clean: frontend-down shipping-down cart-down payment-down queue-master-down catalogue-down user-down orders-down 

down: clean cluster-down

microservices-up: frontend cart-install catalogue-install orders-install payment-install user-install shipping-install queue-master-install

tekton:
	kubectl apply -f https://storage.googleapis.com/tekton-releases/pipeline/latest/release.yaml
	kubectl apply -f https://storage.googleapis.com/tekton-releases/dashboard/latest/tekton-dashboard-release.yaml
	kubectl patch svc tekton-dashboard -n tekton-pipelines --type='json' -p '[{"op":"replace","path":"/spec/type","value":"NodePort"}]'
cli:
	sudo apt update
	sudo apt install -y gnupg
	sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 3EFE0E0A2F2F60AA
	echo "deb http://ppa.launchpad.net/tektoncd/cli/ubuntu eoan main"|sudo tee /etc/apt/sources.list.d/tektoncd-ubuntu-cli.list
	sudo apt update && sudo apt install -y tektoncd-cli
namespaces:
	kubectl create namespace test
	kubectl create namespace prod
	kubectl create namespace ingress-nginx
	kubectl create namespace logging
	kubectl create namespace monitoring
install-ingress:
	echo "Ingress: install" | tee -a output.log
	kubectl apply -n ingress-nginx -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-0.32.0/deploy/static/provider/cloud/deploy.yaml | tee -a output.log
	kubectl wait --namespace ingress-nginx --for=condition=ready pod --selector=app.kubernetes.io/component=controller --timeout=120s

delete-ingress:
	echo "Ingress: delete" | tee -a output.log
	kubectl delete -n ingress -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-0.32.0/deploy/static/provider/cloud/deploy.yaml | tee -a output.log 2>/dev/null | true

elk:
	helm repo add elastic https://helm.elastic.co
	helm repo add fluent https://fluent.github.io/helm-charts
	helm repo update
	helm install elasticsearch elastic/elasticsearch --version=7.9.0 --namespace=logging
	helm install fluent-bit fluent/fluent-bit --namespace=logging
	helm install kibana elastic/kibana --version=7.9.0 --namespace=logging --set service.type=NodePort
	kubectl apply -f ELK/ingress.yaml -n logging

delete-elk:
	helm delete -n logging elasticsearch
	helm delete -n logging fluent-bit
	helm delete -n logging kibana

install-prometheus:
	helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
	helm repo update
	helm install -f prograf/prometheus-values.yaml prometheus prometheus-community/prometheus -n monitoring | tee -a output.log

delete-prometheus:
	helm delete -n monitoring prometheus

install-grafana:
	helm repo add grafana https://grafana.github.io/helm-charts
	helm repo update
	helm install -f prograf/grafana-values.yaml grafana grafana/grafana -n monitoring | tee -a output.log
	echo "Grafana node port "
	echo "$(kubectl get --namespace monitoring -o jsonpath="{.spec.ports[0].nodePort}" services grafana)"
delete-grafana:
	helm delete -n monitoring grafana
main:
	kubectl apply -f cicd/main/sa.yaml -n test
	kubectl apply -f cicd/main/role.yaml

frontend:
	kubectl apply -f cicd/frontend/tasks/pipelineResource.yaml -n test 
	kubectl apply -f cicd/frontend/tasks/task.yaml -n test 
	kubectl apply -f cicd/frontend/tasks/deploy-using-kubectl.yaml -n test 
	kubectl apply -f cicd/frontend/tasks/run-test.yaml -n test 
	kubectl apply -f cicd/frontend/tasks/deploy-to-prod.yaml -n test 
	kubectl apply -f cicd/frontend/tasks/pipeline/pipeline.yaml -n test 
	kubectl apply -f cicd/frontend/tasks/pipeline/pipelinerun.yaml -n test
frontend-down:
	kubectl delete -f cicd/frontend/tasks/pipelineResource.yaml -n test 
	kubectl delete -f cicd/frontend/tasks/task.yaml -n test 
	kubectl delete -f cicd/frontend/tasks/deploy-using-kubectl.yaml -n test
	kubectl apply -f cicd/frontend/tasks/deploy-test.yaml -n test 
	kubectl apply -f cicd/frontend/tasks/deploy-to-prod.yaml -n test
	kubectl delete -f cicd/frontend/tasks/pipeline/pipeline.yaml -n test 
	kubectl delete -f cicd/frontend/tasks/pipeline/pipelinerun.yaml -n test
cart-install:
	kubectl apply -f cicd/carts/tasks/pipelineResource.yaml -n test  
	kubectl apply -f cicd/carts/tasks/task.yaml -n test 
	kubectl apply -f cicd/carts/tasks/deploy-carts.yaml -n test 
	kubectl apply -f cicd/carts/tasks/run-test.yaml -n test 
	kubectl apply -f cicd/carts/tasks/deploy-to-prod.yaml -n test 
	kubectl apply -f cicd/carts/tasks/pipeline/pipeline.yaml -n test 
	kubectl apply -f cicd/carts/tasks/pipeline/pipelinerun.yaml -n test 
cart-down:
	kubectl delete -f cicd/carts/tasks/pipelineResource.yaml -n test 
	kubectl delete -f cicd/carts/tasks/task.yaml -n test 
	kubectl delete -f cicd/carts/tasks/deploy-carts.yaml -n test 
	kubectl delete -f cicd/carts/tasks/run-test.yaml -n test 
	kubectl delete -f cicd/carts/tasks/deploy-to-prod.yaml -n test
	kubectl delete -f cicd/carts/tasks/pipeline/pipeline.yaml -n test 
	kubectl delete -f cicd/carts/tasks/pipeline/pipelinerun.yaml -n test
catalogue-install:
	kubectl apply -f cicd/catalogue/tasks/pipelineResource.yaml -n test 
	kubectl apply -f cicd/catalogue/tasks/task.yaml -n test 
	kubectl apply -f cicd/catalogue/catalogue-db/tasks/task.yaml -n test 
	kubectl apply -f cicd/catalogue/tasks/deploy-catalogue.yaml -n test 
	kubectl apply -f cicd/catalogue/tasks/run-test.yaml -n test 
	kubectl apply -f cicd/catalogue/tasks/deploy-to-prod.yaml -n test 
	kubectl apply -f cicd/catalogue/tasks/pipeline/pipeline.yaml -n test 
	kubectl apply -f cicd/catalogue/tasks/pipeline/pipelinerun.yaml -n test 
catalogue-down:
	kubectl delete -f cicd/catalogue/tasks/pipelineResource.yaml -n test
	kubectl delete -f cicd/catalogue/tasks/task.yaml -n test 
	kubectl delete -f cicd/catalogue/catalogue-db/tasks/task.yaml -n test 
	kubectl delete -f cicd/catalogue/tasks/deploy-catalogue.yaml -n test 
	kubectl delete -f cicd/catalogue/tasks/run-test.yaml -n test 
	kubectl delete -f cicd/catalogue/tasks/deploy-to-prod.yaml -n test 
	kubectl delete -f cicd/catalogue/tasks/pipeline/pipeline.yaml -n test 
	kubectl delete -f cicd/catalogue/tasks/pipeline/pipelinerun.yaml -n test 

orders-install:
	kubectl apply -f cicd/orders/tasks/pipelineResource.yaml -n test 
	kubectl apply -f cicd/orders/tasks/task.yaml -n test 
	kubectl apply -f cicd/orders/tasks/deploy-using-kubectl.yaml -n test 
	kubectl apply -f cicd/orders/tasks/run-test.yaml -n test 
	kubectl apply -f cicd/orders/tasks/deploy-to-prod.yaml -n test 
	kubectl apply -f cicd/orders/tasks/pipeline/pipeline.yaml -n test 
	kubectl apply -f cicd/orders/tasks/pipeline/pipelinerun.yaml -n test 
orders-down:
	kubectl delete -f cicd/orders/tasks/pipelineResource.yaml -n test 
	kubectl delete -f cicd/orders/tasks/task.yaml -n test 
	kubectl delete -f cicd/orders/tasks/deploy-using-kubectl.yaml -n test 
	kubectl delete -f cicd/orders/tasks/run-test.yaml -n test 
	kubectl delete -f cicd/orders/tasks/deploy-to-prod.yaml -n test 
	kubectl delete -f cicd/orders/tasks/pipeline/pipeline.yaml -n test 
	kubectl delete -f cicd/orders/tasks/pipeline/pipelinerun.yaml -n test 
payment-install:
	kubectl apply -f cicd/payment/tasks/pipelineResource.yaml -n test 
	kubectl apply -f cicd/payment/tasks/task.yaml -n test 
	kubectl apply -f cicd/payment/tasks/deploy-using-kubectl.yaml -n test 
	kubectl apply -f cicd/payment/tasks/run-test.yaml -n test  
	kubectl apply -f cicd/payment/tasks/deploy-to-prod.yaml -n test 
	kubectl apply -f cicd/payment/tasks/pipeline/pipeline.yaml -n test  
	kubectl apply -f cicd/payment/tasks/pipeline/pipelinerun.yaml -n test 
payment-down:
	kubectl delete -f cicd/payment/tasks/pipelineResource.yaml -n test 
	kubectl delete -f cicd/payment/tasks/task.yaml -n test 
	kubectl delete -f cicd/payment/tasks/deploy-using-kubectl.yaml -n test 
	kubectl delete -f cicd/payment/tasks/deploy-to-prod.yaml -n test 
	kubectl delete -f cicd/payment/tasks/run-test.yaml -n test 
	kubectl delete -f cicd/payment/tasks/pipeline/pipeline.yaml -n test 
	kubectl delete -f cicd/payment/tasks/pipeline/pipelinerun.yaml -n test 
user-install:
	kubectl apply -f cicd/user/tasks/pipelineResource.yaml -n test 
	kubectl apply -f cicd/user/tasks/task.yaml -n test 
	kubectl apply -f cicd/user/user-db/tasks/task.yaml -n test 
	kubectl apply -f cicd/user/tasks/deploy-using-kubectl.yaml -n test 
	kubectl apply -f cicd/user/tasks/run-test.yaml -n test 
	kubectl apply -f cicd/user/tasks/deploy-to-prod.yaml -n test  
	kubectl apply -f cicd/user/tasks/pipeline/pipeline.yaml -n test 
	kubectl apply -f cicd/user/tasks/pipeline/pipelinerun.yaml -n test 

user-down:
	kubectl delete -f cicd/user/tasks/pipelineResource.yaml -n test 
	kubectl delete -f cicd/user/tasks/task.yaml -n test 
	kubectl delete -f cicd/user/user-db/tasks/task.yaml -n test 
	kubectl delete -f cicd/user/tasks/deploy-using-kubectl.yaml -n test 
	kubectl delete -f cicd/user/tasks/run-test.yaml -n test 
	kubectl delete -f cicd/user/tasks/deploy-to-prod.yaml -n test 
	kubectl delete -f cicd/user/tasks/pipeline/pipeline.yaml -n test 
	kubectl delete -f cicd/user/tasks/pipeline/pipelinerun.yaml -n test

shipping-install:
	kubectl apply -f cicd/shipping/tasks/pipelineResource.yaml -n test 
	kubectl apply -f cicd/shipping/tasks/task.yaml -n test 
	kubectl apply -f cicd/shipping/tasks/deploy-using-kubectl.yaml -n test 
	kubectl apply -f cicd/shipping/tasks/run-test.yaml -n test 
	kubectl apply -f cicd/shipping/tasks/deploy-to-prod.yaml -n test 
	kubectl apply -f cicd/shipping/tasks/pipeline/pipeline.yaml -n test 
	kubectl apply -f cicd/shipping/tasks/pipeline/pipelinerun.yaml -n test 
shipping-down:
	kubectl delete -f cicd/shipping/tasks/pipelineResource.yaml -n test 
	kubectl delete -f cicd/shipping/tasks/task.yaml -n test 
	kubectl delete -f cicd/shipping/tasks/deploy-using-kubectl.yaml -n test 
	kubectl delete -f cicd/shipping/tasks/run-test.yaml -n test 
	kubectl delete -f cicd/shipping/tasks/deploy-to-prod.yaml -n test 
	kubectl delete -f cicd/shipping/tasks/pipeline/pipeline.yaml -n test 
	kubectl delete -f cicd/shipping/tasks/pipeline/pipelinerun.yaml -n test 
queue-master-install:
	kubectl apply -f cicd/queue-master/tasks/pipelineResource.yaml -n test 
	kubectl apply -f cicd/queue-master/tasks/task.yaml -n test 
	kubectl apply -f cicd/queue-master/tasks/deploy-using-kubectl.yaml -n test 
	kubectl apply -f cicd/queue-master/tasks/run-test.yaml -n test 
	kubectl apply -f cicd/queue-master/tasks/deploy-to-prod.yaml -n test 
	kubectl apply -f cicd/queue-master/tasks/pipeline/pipeline.yaml -n test 
	kubectl apply -f cicd/queue-master/tasks/pipeline/pipelinerun.yaml -n test 
queue-master-down:
	kubectl delete -f cicd/queue-master/tasks/pipelineResource.yaml -n test 
	kubectl delete -f cicd/queue-master/tasks/task.yaml -n test 
	kubectl delete -f cicd/queue-master/tasks/deploy-using-kubectl.yaml -n test
	kubectl delete -f cicd/queue-master/tasks/run-test.yaml -n test 
	kubectl delete -f cicd/queue-master/tasks/deploy-to-prod.yaml -n test  
	kubectl delete -f cicd/queue-master/tasks/pipeline/pipeline.yaml -n test 
	kubectl delete -f cicd/queue-master/tasks/pipeline/pipelinerun.yaml -n test 
logs:
	tkn pr logs -f -n test
