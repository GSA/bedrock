up:
	docker-compose up -d
build:
	docker-compose build
update:
	docker-compose run --rm app composer update
clean:
	docker-compose down -v
	rm -rf web/app/mu-plugins/*/ web/app/plugins/* web/app/uploads/* web/app/themes web/wp vendor

setup:
	docker-compose run --rm app composer install --no-dev
	docker-compose run --rm app wp core install --url=http://localhost:8000 --title=Data.gov --admin_user=admin --admin_email=admin@example.com --allow-root
	docker-compose run --rm app wp plugin activate --all --allow-root
	docker-compose run --rm app wp theme activate roots-nextdatagov --allow-root

test:
	curl --silent --fail http://localhost:8000

.PHONY: clean test
