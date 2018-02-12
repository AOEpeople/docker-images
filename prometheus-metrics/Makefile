.PHONY: docker

build: Dockerfile
	docker build -t aoepeople/prometheus-metrics:0.4 .
	docker tag aoepeople/prometheus-metrics:0.4 aoepeople/prometheus-metrics:latest

push: build
	docker push aoepeople/prometheus-metrics:0.4
	docker push aoepeople/prometheus-metrics:latest