VERSION=0.3
REPO=aoepeople/basics

.PHONY: build push

build:
	# docker build -t "${REPO}:${VERSION}" .
	docker build --no-cache -t "${REPO}:${VERSION}" .
	docker tag ${REPO}:${VERSION} ${REPO}:latest

push: build
	docker push ${REPO}:${VERSION}
	docker push ${REPO}:latest
