NAME = saloyiana/catalogue
DBNAME = saloyiana/catalogue-db

.PHONY: build

build:
	docker build -t $(NAME) Dockerfile .
	docker build -t $(DBNAME) -f Dockerfile-db .
