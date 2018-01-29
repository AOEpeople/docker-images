.PHONY: docker

build: Dockerfile
	docker build -t aoepeople/prometheus-metrics:0.1 .
	docker tag aoepeople/prometheus-metrics:0.1 aoepeople/prometheus-metrics:latest

push: build
	docker push aoepeople/prometheus-metrics:0.1
	docker push aoepeople/prometheus-metrics:latest