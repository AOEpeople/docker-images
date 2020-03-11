.PHONY: docker

build: Dockerfile
	docker build -t aoepeople/phptestenv:latest .

push: build
	docker tag aoepeople/phptestenv:latest aoepeople/phptestenv:0.0.3
	docker push aoepeople/phptestenv:0.0.3

