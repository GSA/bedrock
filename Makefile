.PHONY: build clean configure test up

build:
	docker-compose build

clean:
	docker-compose down -v

configure:
	docker-compose run --rm app composer install --no-dev
	docker-compose run --rm app wp core install --url=http://localhost:8000 --title=Data.gov --admin_user=admin --admin_email=admin@example.com --allow-root
	docker-compose run --rm app wp plugin activate --all --allow-root
	docker-compose run --rm app wp theme activate roots-nextdatagov --allow-root

test:
	docker-compose -f docker-compose.yml -f docker-compose.test.yml build test
	docker-compose -f docker-compose.yml -f docker-compose.test.yml up --abort-on-container-exit test

up:
	docker-compose up
