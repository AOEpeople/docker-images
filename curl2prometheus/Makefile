.PHONY: docker

build: Dockerfile
	docker build -t aoepeople/curl2prometheus:0.0.5 .
	docker tag aoepeople/curl2prometheus:0.0.5 aoepeople/curl2prometheus:latest

push: build
	docker push aoepeople/curl2prometheus:0.0.5
	docker push aoepeople/curl2prometheus:latest
