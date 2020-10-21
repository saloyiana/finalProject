#FIRST STEP:

.PHONY:
default: cluster cicd cli namespaces install-ingress main 

cluster:
	k3d cluster create labs \
	    -p 80:80@loadbalancer \
	    -p 443:443@loadbalancer \
	    -p 30000-32767:30000-32767@server[0] \
	    -v /etc/machine-id:/etc/machine-id:ro \
	    -v /var/log/journal:/var/log/journal:ro \
	    -v /var/run/docker.sock:/var/run/docker.sock \
	    --k3s-server-arg '--no-deploy=traefik' \
	    --agents 3
cicd:
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

install-ingress:
	echo "Ingress: install" | tee -a output.log
	kubectl apply -n ingress-nginx -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-0.32.0/deploy/static/provider/cloud/deploy.yaml | tee -a output.log
	kubectl wait --namespace ingress-nginx --for=condition=ready pod --selector=app.kubernetes.io/component=controller --timeout=120s

delete-ingress:
	echo "Ingress: delete" | tee -a output.log
	kubectl delete -n ingress -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-0.32.0/deploy/static/provider/cloud/deploy.yaml | tee -a output.log 2>/dev/null | true

main:
	kubectl apply -f cicd/frontend/tasks/main/sa.yaml -f cicd/frontend/tasks/main/role.yaml -n test
frontend:
	kubectl apply -f cicd/frontend/tasks/pipelineResource.yaml -n test 
	kubectl apply -f cicd/frontend/tasks/task.yaml -n test
	kubectl apply -f cicd/frontend/tasks/deploy-using-kubectl.yaml -n test 
	kubectl apply -f cicd/frontend/tasks/pipeline/pipeline.yaml -n test
	kubectl apply -f cicd/frontend/tasks/pipeline/pipelinerun.yaml -n test 
frontend-down:
	kubectl delete -f cicd/frontend/tasks/pipelineResource.yaml -n test 
	kubectl delete -f cicd/frontend/tasks/task.yaml -n test
	kubectl delete -f cicd/frontend/tasks/deploy-using-kubectl.yaml -n test 
	kubectl delete -f cicd/frontend/tasks/pipeline/pipeline.yaml -n test
	kubectl delete -f cicd/frontend/tasks/pipeline/pipelinerun.yaml -n test 
cart:
	kubectl apply -f cicd/carts/tasks/pipelineResource.yaml -n test 
	kubectl apply -f cicd/carts/tasks/task.yaml -n test
	kubectl apply -f cicd/carts/tasks/deploy-carts.yaml -n test 
	kubectl apply -f cicd/carts/tasks/pipeline/pipeline.yaml -n test
	kubectl apply -f cicd/carts/tasks/pipeline/pipelinerun.yaml -n test 
cart-down:
	kubectl delete -f cicd/carts/tasks/pipelineResource.yaml -n test 
	kubectl delete -f cicd/carts/tasks/task.yaml -n test
	kubectl delete -f cicd/carts/tasks/deploy-carts.yaml -n test 
	kubectl delete -f cicd/carts/tasks/pipeline/pipeline.yaml -n test
	kubectl delete -f cicd/carts/tasks/pipeline/pipelinerun.yaml -n test
catalogue-install:
	kubectl apply -f cicd/catalogue/tasks/pipelineResource.yaml -n test 
	kubectl apply -f cicd/catalogue/tasks/task.yaml -n test
	kubectl apply -f cicd/catalogue/catalogue-db/tasks/task.yaml -n test
	kubectl apply -f cicd/catalogue/tasks/deploy-catalogue.yaml -n test 
	kubectl apply -f cicd/catalogue/tasks/pipeline/pipeline.yaml -n test
	kubectl apply -f cicd/catalogue/tasks/pipeline/pipelinerun.yaml -n test
catalogue-down:
	kubectl delete -f cicd/catalogue/tasks/pipelineResource.yaml -n test 
	kubectl delete -f cicd/catalogue/tasks/task.yaml -n test
	kubectl delete -f cicd/catalogue/catalogue-db/tasks/task.yaml -n test
	kubectl delete -f cicd/catalogue/tasks/deploy-catalogue.yaml -n test 
	kubectl delete -f cicd/catalogue/tasks/pipeline/pipeline.yaml -n test
	kubectl delete -f cicd/catalogue/tasks/pipeline/pipelinerun.yaml -n test

orders-install:
	kubectl apply -f cicd/orders/tasks/pipelineResource.yaml -n test 
	kubectl apply -f cicd/orders/tasks/task.yaml -n test
	kubectl apply -f cicd/orders/tasks/deploy-using-kubectl.yaml -n test 
	kubectl apply -f cicd/orders/tasks/pipeline/pipeline.yaml -n test
	kubectl apply -f cicd/orders/tasks/pipeline/pipelinerun.yaml -n test
orders-down:
	kubectl delete -f cicd/orders/tasks/pipelineResource.yaml -n test 
	kubectl delete -f cicd/orders/tasks/task.yaml -n test
	kubectl delete -f cicd/orders/tasks/deploy-using-kubectl.yaml -n test 
	kubectl delete -f cicd/orders/tasks/pipeline/pipeline.yaml -n test
	kubectl delete -f cicd/orders/tasks/pipeline/pipelinerun.yaml -n test
payment-install:
	kubectl apply -f cicd/payment/tasks/pipelineResource.yaml -n test 
	kubectl apply -f cicd/payment/tasks/task.yaml -n test
	kubectl apply -f cicd/payment/tasks/deploy-using-kubectl.yaml -n test 
	kubectl apply -f cicd/payment/tasks/pipeline/pipeline.yaml -n test
	kubectl apply -f cicd/payment/tasks/pipeline/pipelinerun.yaml -n test
payment-down:
	kubectl delete -f cicd/payment/tasks/pipelineResource.yaml -n test 
	kubectl delete -f cicd/payment/tasks/task.yaml -n test
	kubectl delete -f cicd/payment/tasks/deploy-using-kubectl.yaml -n test 
	kubectl delete -f cicd/payment/tasks/pipeline/pipeline.yaml -n test
	kubectl delete -f cicd/payment/tasks/pipeline/pipelinerun.yaml -n test
user:
	kubectl apply -f cicd/user/tasks/pipelineResource.yaml -n test 
	kubectl apply -f cicd/user/tasks/task.yaml -n test
	kubectl apply -f cicd/user/user-db/tasks/task.yaml -n test
	kubectl apply -f cicd/user/tasks/deploy-using-kubectl.yaml -n test 
	kubectl apply -f cicd/user/tasks/pipeline/pipeline.yaml -n test
	kubectl apply -f cicd/user/tasks/pipeline/pipelinerun.yaml -n test

user-down:
	kubectl delete -f cicd/user/tasks/pipelineResource.yaml -n test 
	kubectl delete -f cicd/user/tasks/task.yaml -n test
	kubectl delete -f cicd/user/user-db/tasks/task.yaml -n test
	kubectl delete -f cicd/user/tasks/deploy-using-kubectl.yaml -n test 
	kubectl delete -f cicd/user/tasks/pipeline/pipeline.yaml -n test
	kubectl delete -f cicd/user/tasks/pipeline/pipelinerun.yaml -n test

shipping-install:
	kubectl apply -f cicd/shipping/tasks/pipelineResource.yaml -n test 
	kubectl apply -f cicd/shipping/tasks/task.yaml -n test
	kubectl apply -f cicd/shipping/tasks/deploy-using-kubectl.yaml -n test 
	kubectl apply -f cicd/shipping/tasks/pipeline/pipeline.yaml -n test
	kubectl apply -f cicd/shipping/tasks/pipeline/pipelinerun.yaml -n test
shipping-down:
	kubectl delete -f cicd/shipping/tasks/pipelineResource.yaml -n test 
	kubectl delete -f cicd/shipping/tasks/task.yaml -n test
	kubectl delete -f cicd/shipping/tasks/deploy-using-kubectl.yaml -n test 
	kubectl delete -f cicd/shipping/tasks/pipeline/pipeline.yaml -n test
	kubectl delete -f cicd/shipping/tasks/pipeline/pipelinerun.yaml -n test
queue-master-install:
	kubectl apply -f cicd/queue-master/tasks/pipelineResource.yaml -n test 
	kubectl apply -f cicd/queue-master/tasks/task.yaml -n test
	kubectl apply -f cicd/queue-master/tasks/deploy-using-kubectl.yaml -n test 
	kubectl apply -f cicd/queue-master/tasks/pipeline/pipeline.yaml -n test
	kubectl apply -f cicd/queue-master/tasks/pipeline/pipelinerun.yaml -n test
queue-master-down:
	kubectl delete -f cicd/queue-master/tasks/pipelineResource.yaml -n test 
	kubectl delete -f cicd/queue-master/tasks/task.yaml -n test
	kubectl delete -f cicd/queue-master/tasks/deploy-using-kubectl.yaml -n test 
	kubectl delete -f cicd/queue-master/tasks/pipeline/pipeline.yaml -n test
	kubectl delete -f cicd/queue-master/tasks/pipeline/pipelinerun.yaml -n test


logs:
	tkn pr logs -f -n test
