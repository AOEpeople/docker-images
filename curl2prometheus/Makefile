VERSION=$(shell git describe --tags --always --dirty --abbrev=3)

.PHONY: build push

build: Dockerfile
	docker build -t aoepeople/curl2prometheus:${VERSION} .
	docker tag aoepeople/curl2prometheus:${VERSION} aoepeople/curl2prometheus:latest

push: build
	docker push aoepeople/curl2prometheus:${VERSION}
	docker push aoepeople/curl2prometheus:latest
