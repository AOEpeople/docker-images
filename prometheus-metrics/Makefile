.PHONY: docker

build: Dockerfile
	docker build -t aoepeople/prometheus-metrics:0.3 .
	docker tag aoepeople/prometheus-metrics:0.3 aoepeople/prometheus-metrics:latest

push: build
	docker push aoepeople/prometheus-metrics:0.3
	docker push aoepeople/prometheus-metrics:latest