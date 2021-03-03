.PHONY: docker

build: Dockerfile
	docker build -t aoepeople/phptestenv:latest .

push: build
	docker tag aoepeople/phptestenv:latest aoepeople/phptestenv:0.0.4
	docker push aoepeople/phptestenv:0.0.4

