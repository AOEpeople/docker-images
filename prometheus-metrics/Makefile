.PHONY: docker

build: Dockerfile
	docker build -t aoepeople/prometheus-metrics:0.7 .
	docker tag aoepeople/prometheus-metrics:0.7 aoepeople/prometheus-metrics:latest

push: build
	docker push aoepeople/prometheus-metrics:0.7
	docker push aoepeople/prometheus-metrics:latest