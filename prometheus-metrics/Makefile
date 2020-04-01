VERSION=0.10.0
REPO=aoepeople/prometheus-metrics

.PHONY: build push

build:
	docker build -t "${REPO}:${VERSION}" .
	docker tag ${REPO}:${VERSION} ${REPO}:latest

push: build
	docker push ${REPO}:${VERSION}
	docker push ${REPO}:latest