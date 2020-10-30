# The Final Project of the DevOps Bootcamp


This project done as one of the requirement to complete the bootcamp. It aims to demonstrate the skills that have been gained in the last four months.


##Project's requirement overview:   
One of the main given instructions is to deploy the entire system (to test, test it, if pass, start deploying to production) using one or two commands in 21 days duration. Also, ELK and Grafana is a must.  

###The platform:
Eight microservices (e.g. frontend, payment, carts, and orders) need to be build based on the microservices architecture.  

###Tools:
Required different tools to be used such as:  
Docker as containerization tool  
Kubernetes as an orchestration tool  
Tekton as CICD tool  
Elasticsearch and Kibana (ELK) for logging 
Prometheus and Grafana for monitoring  

###Rules to follow:   
One of the main given instructions is to deploy the entire system (to test, test it, if pass, start deploying to production) using one or two commands in 21 days duration. Also, ELK and Grafana is a must.  


##What we have so far (result): 
Eight tekton pipelines (each microservice has one), each has at least five tasks,  work as follow:  
1- build and push the required image to docker hub, if successfully done, 
2- Deploy microservices using Kubernetes deployment and service that uses the same image that just built to test namespace, if successfully done,
3- Run the test against the test namespace, if it is a pass 
4- Clean the test environment, and then
5- deploy the entire platform to prod namespace  

Also, using make elk,  the elastic search and kibana will be ready, and make grafana, will be ready.

##My instruction :) :

make up  
will build the cluster , deploy tekton and tekton cli as well , namespaces , configure elf and grafana.  

Then you need to add the secret ( until the vault be ready )  

make build   

will run the pipelines that one the other hand will deploy the microservices to test namespace, run the test, and finally deploy them to prod namespace. 

