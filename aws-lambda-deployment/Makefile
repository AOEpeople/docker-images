.PHONY: docker

build: Dockerfile
	docker build -t aoepeople/aws-lambda-deployment:0.2 .
	docker tag aoepeople/aws-lambda-deployment:0.2 aoepeople/aws-lambda-deployment:latest

push: build
	docker push aoepeople/aws-lambda-deployment:0.2
	docker push aoepeople/aws-lambda-deployment:latest