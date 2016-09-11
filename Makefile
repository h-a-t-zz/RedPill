NAME = programmez
VERSION ?= latest
run:
	docker run --name $(NAME)-db -e 'MYSQL_RANDOM_ROOT_PASSWORD=yes' -e 'MYSQL_USER=user' -e 'MYSQL_PASSWORD=password' -e 'MYSQL_DATABASE=sqli' -v $(PWD)/src/sql/staging.sql:/docker-entrypoint-initdb.d/staging.sql -d mysql/mysql-server:5.6
	docker run -d -P --name $(NAME)-php -v $(PWD)/src/php:/var/www/html  --link $(NAME)-db:db $(NAME)-php:$(VERSION)

build:
	docker build -t $(NAME)-php:$(VERSION) ./src/php

pull:
	docker pull php:5-apache
	docker pull mysql/mysql-server:5.6

stop:
	docker stop $(NAME)-db
	docker stop $(NAME)-php

clean:
	docker rm $(NAME)-db
	docker rm $(NAME)-php
