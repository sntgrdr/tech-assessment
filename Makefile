build:
	docker-compose -f docker-compose.yml up -d db redis backend frontend

bundle.update:
	docker-compose run --rm --no-deps backend bundle update

start:
	docker-compose up

stop:
	docker-compose down

rails.c:
	docker-compose run backend rails c

sh:
	docker-compose run backend sh

db.init:
	docker-compose run backend bundle exec rake db:drop db:create db:migrate db:seed

db.migrate:
	docker-compose run backend bundle exec rake db:migrate

rspec:
	docker-compose run --rm --no-deps backend bundle exec rspec $(FILE)

rubocop:
	docker-compose run --rm --no-deps backend rubocop

rubocop.autofix:
	docker-compose run --rm --no-deps backend rubocop -A
