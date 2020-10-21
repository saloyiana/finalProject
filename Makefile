#FIRST STEP:

.PHONY:
default: cluster tekton cli namespaces main 

cluster:
	k3d cluster create shockShop \
	    -p 80:80@loadbalancer \
	    -p 443:443@loadbalancer \
	    -p 30000-32767:30000-32767@server[0] \
	    -v /etc/machine-id:/etc/machine-id:ro \
	    -v /var/log/journal:/var/log/journal:ro \
	    -v /var/run/docker.sock:/var/run/docker.sock \
	    --agents 3
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
carts-down:
	kubectl delete -f cicd/carts/tasks/pipelineResource.yaml -n test 
	kubectl delete -f cicd/carts/tasks/task.yaml -n test
	kubectl delete -f cicd/carts/tasks/deploy-carts.yaml -n test 
	kubectl delete -f cicd/carts/tasks/pipeline/pipeline.yaml -n test
	kubectl delete -f cicd/carts/tasks/pipeline/pipelinerun.yaml -n test
catalogue:
payment:
shipping:
queue-master:
logs:
	tkn pr logs -f -n test
