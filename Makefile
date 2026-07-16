test:
	./gradlew test

start: run

run:
	./gradlew bootRun

update-gradle:
	./gradlew wrapper --gradle-version 9.2.1

update-deps:
	./gradlew refreshVersions

install:
	./gradlew dependencies

build:
	./gradlew build

lint:
	./gradlew spotlessCheck

lint-fix:
	./gradlew spotlessApply

docker-build:
	docker build -t bulletins-app .

docker-run:
	docker run -p 8080:8080 -p 9091:9090 \
        -e SPRING_PROFILES_ACTIVE=dev \
        -e SPRING_DATASOURCE_URL=${SPRING_DATASOURCE_URL} \
        -e SPRING_DATASOURCE_USERNAME=${SPRING_DATASOURCE_USERNAME} \
        -e SPRING_DATASOURCE_PASSWORD=${SPRING_DATASOURCE_PASSWORD} \
        bulletins-app

docker-stop:
	docker stop $$(docker ps -q --filter ancestor=bulletins-app)

docker-clean:
	docker rmi bulletins-app


.PHONY: build