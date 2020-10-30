# CICD:


## Main: 

There are the required service account and roles.  
- To deploy them, run `make main`

## Each microservices dir: 
There are three dirs:  
- k8s: contains the k8s manifests.
- tasks: the required tasks and its taskruns.  
- pipeline: the pipeline and its pipelinerun. 

## e2e-test:
There is the task to build and push the test image and its task run.   

#### some of them will have 4th dirs, the 4th for the db's tasks. 
