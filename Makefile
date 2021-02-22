up:
	docker-compose up -d
build:
	docker-compose build
update:
	docker-compose run --rm app composer update
clean:
	docker-compose down -v
	rm -rf web/app/mu-plugins/*/ web/app/plugins/* web/app/uploads/* web/app/themes web/wp lib/vendor

setup:
	# Install dependencies again as the docker-compose is overwriting
	docker-compose run --rm app composer install --no-dev
	# Wait 10 seconds for db to become available; TODO: ping and run when available
	sleep 10
	docker-compose run --rm app /var/www/lib/vendor/wp-cli/wp-cli/bin/wp core install --url=http://localhost:8000 --title=Data.gov --admin_user=admin --admin_email=admin@example.com --allow-root
	docker-compose run --rm app /var/www/lib/vendor/wp-cli/wp-cli/bin/wp plugin activate --all --allow-root
	docker-compose run --rm app /var/www/lib/vendor/wp-cli/wp-cli/bin/wp theme activate roots-nextdatagov --allow-root

test:
	curl --silent --fail http://localhost:8000

.PHONY: clean test
