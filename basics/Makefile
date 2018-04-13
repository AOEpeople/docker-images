.PHONY: docker

build: Dockerfile
	docker build -t aoepeople/basics:0.2 .
	docker tag aoepeople/basics:0.1 aoepeople/basics:latest

push: build
	docker push aoepeople/basics:0.2
	docker push aoepeople/basics:latest