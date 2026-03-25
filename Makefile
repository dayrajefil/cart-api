up:
	docker-compose up -d

stop:
	docker-compose stop

clean:
	docker-compose down -v --rmi all --remove-orphans

bash:
	docker-compose exec web bash
