# ---------- Builder stage ----------
FROM eclipse-temurin:21-jdk-alpine AS builder

WORKDIR /app

COPY gradlew .
COPY gradle gradle
COPY build.gradle.kts .
COPY settings.gradle.kts .
COPY versions.properties .
COPY gradle/libs.versions.toml gradle/

# Make Gradle wrapper executable
RUN chmod +x gradlew

# Download project dependencies
RUN ./gradlew dependencies --no-daemon

# Copy application source code
COPY src src

# Run tests to validate build
RUN ./gradlew test --no-daemon

# Build the application jar
RUN ./gradlew build -x test --no-daemon


# ---------- Runtime stage ----------
# Use lightweight JRE image for running the application
FROM eclipse-temurin:21-jre-alpine

# Set working directory
WORKDIR /app

# Copy all built jars
COPY --from=builder /app/build/libs/ /app/

# Expose application and actuator ports
EXPOSE 8080 9090

# Run the Spring Boot application
ENTRYPOINT ["java","-jar","/app/project-devops-deploy-0.0.1-SNAPSHOT.jar"]