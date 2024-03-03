# Targets in this file are intended for running inside a virtualenv of the project
# use:
# poetry init - to initialize the venv
# poetry shell - to activate it

DOCKER_COMPOSE_DEV=docker-compose-dev.yml

start-deps:
	docker-compose -f $(DOCKER_COMPOSE_DEV) up


run_tests:
	pytest

black:
	black ./db_verifier ./tests

check_black:
	black --check ./db_verifier ./tests

check_lint:
	pyflakes ./db_verifier ./tests
