VERSION=$(shell git describe --tags --always --dirty --abbrev=3)
REPO=aoepeople/prometheus-metrics

.PHONY: build push

build:
	docker build -t "${REPO}:${VERSION}" .
	docker tag ${REPO}:${VERSION} ${REPO}:latest

push: build
	docker push ${REPO}:${VERSION}
	docker push ${REPO}:latest