.PHONY: docker

build: Dockerfile
	docker build -t aoepeople/mysql-backup-s3:0.4 .

push: build
	docker push aoepeople/mysql-backup-s3:0.4
	docker push aoepeople/mysql-backup-s3:latest
