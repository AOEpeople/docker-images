.PHONY: docker

build: Dockerfile
	docker build -t aoepeople/mysql-backup-s3:0.6 .

push: build
	docker push aoepeople/mysql-backup-s3:0.6
	docker push aoepeople/mysql-backup-s3:latest
