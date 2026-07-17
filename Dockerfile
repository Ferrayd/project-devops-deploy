# ---------- frontend build stage ----------
FROM node:20-alpine AS frontend-build
WORKDIR /app/frontend

COPY frontend/package*.json ./
RUN npm ci --legacy-peer-deps

COPY frontend/ ./
RUN npm run build

# Используем официальный образ с JDK для сборки
FROM eclipse-temurin:21-jdk-alpine AS builder

# Устанавливаем рабочую директорию
WORKDIR /app

# Копируем gradle wrapper и конфигурационные файлы
COPY gradlew .
COPY gradle gradle
COPY build.gradle.kts .
COPY settings.gradle.kts .
COPY versions.properties .
COPY gradle/libs.versions.toml gradle/

# Даем права на выполнение gradlew
RUN chmod +x gradlew

# Копируем исходный код
COPY src src

# Собираем приложение
RUN ./gradlew build -x test --no-daemon

RUN ./gradlew test --no-daemon

# Финальный образ для запуска
FROM eclipse-temurin:21-jre-alpine

WORKDIR /app

# Копируем собранный jar из builder stage
COPY --from=builder /app/build/libs/*.jar app.jar

# Открываем порты
EXPOSE 8080 9090

# Запускаем приложение
ENTRYPOINT ["java", "-jar", "app.jar"]