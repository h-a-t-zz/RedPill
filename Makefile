NAME = phpsqli
VERSION ?= latest
run:
	docker run --name $(NAME)-db -e MYSQL_ROOT_PASSWORD=root -v $(PWD)/src/sql/:/docker-entrypoint-initdb.d/ -d mysql/mysql-server:5.6
	docker run -d -P --name $(NAME)-php -v $(PWD)/src/php:/var/www/html  --link $(NAME)-db:db $(NAME)-php:$(VERSION)

build:
	docker build -t $(NAME)-php:$(VERSION) .
pull:
	docker pull nimmis/apache-php5
	docker pull mysql/mysql-server:5.6

stop:
	docker stop $(NAME)-db
	docker stop $(NAME)-php

rm:
	docker rm $(NAME)-db
	docker rm $(NAME)-php
