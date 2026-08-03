test:
	./gradlew test

run:
	./gradlew run

update-gradle:
	./gradlew wrapper --gradle-version 9.1.0

update-deps:
	./gradlew refreshVersions