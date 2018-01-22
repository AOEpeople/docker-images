.PHONY: docker

build: Dockerfile
	docker build -t aoepeople/aws-lambda-deployment:0.1 .
	docker tag aoepeople/aws-lambda-deployment:0.1 aoepeople/aws-lambda-deployment:latest

push: build
	docker push aoepeople/aws-lambda-deployment:0.1
	docker push aoepeople/aws-lambda-deployment:latest