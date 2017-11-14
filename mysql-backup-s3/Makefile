.PHONY: docker

build: Dockerfile
	docker build -t aoepeople/mysql-backup-s3:0.5 .

push: build
	docker push aoepeople/mysql-backup-s3:0.5
	docker push aoepeople/mysql-backup-s3:latest
