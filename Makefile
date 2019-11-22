.PHONY: build clean configure test up

build:
	docker-compose build

clean:
	docker-compose down -v

configure:
	docker-compose up --detach
	docker-compose exec app composer install
	docker-compose exec app wp core install --url=http://localhost:8000 --title=Data.gov --admin_user=admin --admin_email=admin@example.com --allow-root
	docker-compose exec app wp plugin activate --all --allow-root
	docker-compose exec app wp theme activate roots-nextdatagov --allow-root

test:
	docker-compose -f docker-compose.yml -f docker-compose.test.yml build test
	docker-compose -f docker-compose.yml -f docker-compose.test.yml up --abort-on-container-exit test

up:
	docker-compose up
