VERSION=0.3

.PHONY: build push

build: Dockerfile
	docker build -t aoepeople/aws-lambda-deployment:${VERSION} .
	docker tag aoepeople/aws-lambda-deployment:${VERSION} aoepeople/aws-lambda-deployment:latest

push: build
	docker push aoepeople/aws-lambda-deployment:${VERSION}
	docker push aoepeople/aws-lambda-deployment:latest
