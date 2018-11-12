ifndef DB_VENDOR
	DB_VENDOR=postgres
endif

ifeq ($(DB_VENDOR), postgres)
	unexport NO_DEPS
	DB_HOST=janeway-postgres
	DB_PORT=5432
	DB_NAME=janeway
	DB_USER=janeway-web
	DB_PASSWORD=janeway-web
	CLI_COMMAND=psql --username=$(DB_USER) $(DB_NAME)
endif
ifeq ($(DB_VENDOR), mysql)
	unexport NO_DEPS
	DB_HOST=janeway-mysql
	DB_PORT=3306
	DB_NAME=janeway
	DB_USER=janeway-web
	DB_PASSWORD=janeway-web
	CLI_COMMAND=mysql -u $(DB_USER) -p$(DB_PASSWORD)
endif
ifeq ($(DB_VENDOR), sqlite)
	unexport DB_HOST
	NO_DEPS=true
	CLI_COMMAND=sqlite db/janeway.sqlite
endif

export DB_VENDOR
export DB_HOST
export DB_PORT
export DB_NAME
export DB_USER
export DB_PASSWORD
export NO_DEPS


all: janeway
help:		## Show this help.
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##//'
no-deps:	## Run janeway development server with no other services. Uses sqlite3 database
	unexport DB_DB
	docker-compose run --no-deps --rm --service-ports janeway-web
janeway:	## Run Janeway web server in attached mode. If NO_DEPS is not set, runs all dependant services detached.
	docker-compose run $(NO_DEPS) --rm --service-ports janeway-web $(entrypoint)
command:	## Run Janeway in a container and pass through a django command passed as the CMD environment variable
	bash -c "make janeway entrypoint=\"src/manage.py $(CMD)\""
install:	## Run the install_janeway command inside a container
	touch db/janeway.sqlite
	bash -c "make command CMD=install_janeway"
rebuild:	## Rebuild the Janeway docker image.
	docker-compose build --no-cache
shell:		## Runs the janeway-web service and starts an interactive bash process instead of the webserver
	bash -c "make janeway entrypoint=/bin/bash"
attach:		## Runs an interactive bash process within the currently running janeway-web container
	docker exec -ti `docker ps -q --filter 'name=janeway-web'` /bin/bash
db-client:	## runs the database CLI client interactively within the database container as per the value of DB_VENDOR
	docker exec -ti `docker ps -q --filter 'name=janeway-$(DB_VENDOR)'` $(CLI_COMMAND)
uninstall:	## Removes all janeway related docker containers, docker images and database volumes
	@bash -c "rm -rf db/*"
	@bash -c "docker rm -f `docker ps --filter 'name=janeway*' -aq` >/dev/null 2>&1 | true"
	@bash -c "docker rmi `docker images -q janeway*` >/dev/null 2>&1 | true"
	@echo " Janeway has been uninstalled"
check:		## Runs janeway test suit
	bash -c "make command CMD=test"