VERSION=1.0.3

.PHONY: docker

build: Dockerfile
	docker build -t aoepeople/mysql-backup-s3:${VERSION} .
	docker tag aoepeople/mysql-backup-s3:${VERSION} aoepeople/mysql-backup-s3:latest

push: build
	docker push aoepeople/mysql-backup-s3:${VERSION}
	docker push aoepeople/mysql-backup-s3:latest
