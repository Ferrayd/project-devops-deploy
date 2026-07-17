# ---------- Frontend build ----------
FROM node:20-alpine AS frontend-builder

WORKDIR /frontend

COPY frontend/package*.json ./

RUN npm install

COPY frontend .

RUN npm run build

# ---------- Backend build ----------
FROM eclipse-temurin:21-jdk-alpine AS builder

WORKDIR /app

COPY gradlew .
COPY gradle gradle
COPY build.gradle.kts .
COPY settings.gradle.kts .
COPY versions.properties .

RUN chmod +x gradlew

# cache dependencies
RUN ./gradlew dependencies --no-daemon

# copy source
COPY src src

# copy frontend build into spring static dir
COPY --from=frontend-builder /frontend/dist src/main/resources/static

RUN ./gradlew build -x test --no-daemon



# ---------- Runtime ----------
FROM eclipse-temurin:21-jre-alpine

WORKDIR /app

COPY --from=builder /app/build/libs/*SNAPSHOT.jar /app/app.jar

EXPOSE 8080 9090

ENTRYPOINT ["java","-jar","/app/app.jar"]