#FIRST STEP:

.PHONY: cluster namespaces tekton cli
up: cluster namespaces tekton cli install-ingress main frontend cart-install catalogue-install orders-install payment-install user-install shipping-install queue-master-install 

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
install-ingress:
	echo "Ingress: install" | tee -a output.log
	kubectl apply -n ingress-nginx -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-0.32.0/deploy/static/provider/cloud/deploy.yaml | tee -a output.log
	kubectl wait --namespace ingress-nginx --for=condition=ready pod --selector=app.kubernetes.io/component=controller --timeout=120s

delete-ingress:
	echo "Ingress: delete" | tee -a output.log
	kubectl delete -n ingress -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-0.32.0/deploy/static/provider/cloud/deploy.yaml | tee -a output.log 2>/dev/null | true

main:
	kubectl apply -f cicd/main/sa.yaml -f cicd/main/role.yaml

frontend:
	kubectl apply -f cicd/frontend/tasks/pipelineResource.yaml
	kubectl apply -f cicd/frontend/tasks/task.yaml
	kubectl apply -f cicd/frontend/tasks/deploy-using-kubectl.yaml
	kubectl apply -f cicd/frontend/tasks/pipeline/pipeline.yaml
	kubectl apply -f cicd/frontend/tasks/pipeline/pipelinerun.yaml
frontend-down:
	kubectl delete -f cicd/frontend/tasks/pipelineResource.yaml
	kubectl delete -f cicd/frontend/tasks/task.yaml
	kubectl delete -f cicd/frontend/tasks/deploy-using-kubectl.yaml
	kubectl delete -f cicd/frontend/tasks/pipeline/pipeline.yaml
	kubectl delete -f cicd/frontend/tasks/pipeline/pipelinerun.yaml
cart-install:
	kubectl apply -f cicd/carts/tasks/pipelineResource.yaml 
	kubectl apply -f cicd/carts/tasks/task.yaml
	kubectl apply -f cicd/carts/tasks/deploy-carts.yaml
	kubectl apply -f cicd/carts/tasks/pipeline/pipeline.yaml
	kubectl apply -f cicd/carts/tasks/pipeline/pipelinerun.yaml
cart-down:
	kubectl delete -f cicd/carts/tasks/pipelineResource.yaml
	kubectl delete -f cicd/carts/tasks/task.yaml
	kubectl delete -f cicd/carts/tasks/deploy-carts.yaml
	kubectl delete -f cicd/carts/tasks/pipeline/pipeline.yaml
	kubectl delete -f cicd/carts/tasks/pipeline/pipelinerun.yaml
catalogue-install:
	kubectl apply -f cicd/catalogue/tasks/pipelineResource.yaml
	kubectl apply -f cicd/catalogue/tasks/task.yaml
	kubectl apply -f cicd/catalogue/catalogue-db/tasks/task.yaml 
	kubectl apply -f cicd/catalogue/tasks/deploy-catalogue.yaml
	kubectl apply -f cicd/catalogue/tasks/pipeline/pipeline.yaml
	kubectl apply -f cicd/catalogue/tasks/pipeline/pipelinerun.yaml
catalogue-down:
	kubectl delete -f cicd/catalogue/tasks/pipelineResource.yaml 
	kubectl delete -f cicd/catalogue/tasks/task.yaml 
	kubectl delete -f cicd/catalogue/catalogue-db/tasks/task.yaml 
	kubectl delete -f cicd/catalogue/tasks/deploy-catalogue.yaml 
	kubectl delete -f cicd/catalogue/tasks/pipeline/pipeline.yaml 
	kubectl delete -f cicd/catalogue/tasks/pipeline/pipelinerun.yaml 

orders-install:
	kubectl apply -f cicd/orders/tasks/pipelineResource.yaml
	kubectl apply -f cicd/orders/tasks/task.yaml
	kubectl apply -f cicd/orders/tasks/deploy-using-kubectl.yaml 
	kubectl apply -f cicd/orders/tasks/pipeline/pipeline.yaml 
	kubectl apply -f cicd/orders/tasks/pipeline/pipelinerun.yaml 
orders-down:
	kubectl delete -f cicd/orders/tasks/pipelineResource.yaml 
	kubectl delete -f cicd/orders/tasks/task.yaml 
	kubectl delete -f cicd/orders/tasks/deploy-using-kubectl.yaml 
	kubectl delete -f cicd/orders/tasks/pipeline/pipeline.yaml 
	kubectl delete -f cicd/orders/tasks/pipeline/pipelinerun.yaml 
payment-install:
	kubectl apply -f cicd/payment/tasks/pipelineResource.yaml 
	kubectl apply -f cicd/payment/tasks/task.yaml 
	kubectl apply -f cicd/payment/tasks/deploy-using-kubectl.yaml  
	kubectl apply -f cicd/payment/tasks/pipeline/pipeline.yaml 
	kubectl apply -f cicd/payment/tasks/pipeline/pipelinerun.yaml 
payment-down:
	kubectl delete -f cicd/payment/tasks/pipelineResource.yaml 
	kubectl delete -f cicd/payment/tasks/task.yaml 
	kubectl delete -f cicd/payment/tasks/deploy-using-kubectl.yaml 
	kubectl delete -f cicd/payment/tasks/pipeline/pipeline.yaml 
	kubectl delete -f cicd/payment/tasks/pipeline/pipelinerun.yaml 
user-install:
	kubectl apply -f cicd/user/tasks/pipelineResource.yaml
	kubectl apply -f cicd/user/tasks/task.yaml 
	kubectl apply -f cicd/user/user-db/tasks/task.yaml
	kubectl apply -f cicd/user/tasks/deploy-using-kubectl.yaml  
	kubectl apply -f cicd/user/tasks/pipeline/pipeline.yaml 
	kubectl apply -f cicd/user/tasks/pipeline/pipelinerun.yaml 

user-down:
	kubectl delete -f cicd/user/tasks/pipelineResource.yaml 
	kubectl delete -f cicd/user/tasks/task.yaml 
	kubectl delete -f cicd/user/user-db/tasks/task.yaml 
	kubectl delete -f cicd/user/tasks/deploy-using-kubectl.yaml 
	kubectl delete -f cicd/user/tasks/pipeline/pipeline.yaml 
	kubectl delete -f cicd/user/tasks/pipeline/pipelinerun.yaml 

shipping-install:
	kubectl apply -f cicd/shipping/tasks/pipelineResource.yaml 
	kubectl apply -f cicd/shipping/tasks/task.yaml 
	kubectl apply -f cicd/shipping/tasks/deploy-using-kubectl.yaml 
	kubectl apply -f cicd/shipping/tasks/pipeline/pipeline.yaml 
	kubectl apply -f cicd/shipping/tasks/pipeline/pipelinerun.yaml 
shipping-down:
	kubectl delete -f cicd/shipping/tasks/pipelineResource.yaml 
	kubectl delete -f cicd/shipping/tasks/task.yaml 
	kubectl delete -f cicd/shipping/tasks/deploy-using-kubectl.yaml
	kubectl delete -f cicd/shipping/tasks/pipeline/pipeline.yaml 
	kubectl delete -f cicd/shipping/tasks/pipeline/pipelinerun.yaml
queue-master-install:
	kubectl apply -f cicd/queue-master/tasks/pipelineResource.yaml
	kubectl apply -f cicd/queue-master/tasks/task.yaml 
	kubectl apply -f cicd/queue-master/tasks/deploy-using-kubectl.yaml 
	kubectl apply -f cicd/queue-master/tasks/pipeline/pipeline.yaml 
	kubectl apply -f cicd/queue-master/tasks/pipeline/pipelinerun.yaml
queue-master-down:
	kubectl delete -f cicd/queue-master/tasks/pipelineResource.yaml 
	kubectl delete -f cicd/queue-master/tasks/task.yaml 
	kubectl delete -f cicd/queue-master/tasks/deploy-using-kubectl.yaml 
	kubectl delete -f cicd/queue-master/tasks/pipeline/pipeline.yaml 
	kubectl delete -f cicd/queue-master/tasks/pipeline/pipelinerun.yaml

logs:
	tkn pr logs -f
