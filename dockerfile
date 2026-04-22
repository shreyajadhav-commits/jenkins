# Stage 1: Build
FROM eclipse-temurin:17-jdk-alpine AS build
WORKDIR /app

# Install bash and dos2unix to handle Windows-to-Linux line ending issues with mvnw
RUN apk add --no-cache bash dos2unix

COPY pom.xml mvnw ./
COPY .mvn .mvn

# Fix potential Windows line ending issues and make executable
RUN dos2unix mvnw && chmod +x mvnw

# Download dependencies (Layer caching)
RUN ./mvnw dependency:go-offline

COPY src ./src

# Build the application
RUN ./mvnw clean package -DskipTests

# Stage 2: Run
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app

# Use a wildcard to find the JAR regardless of the version name
COPY --from=build /app/target/jenkins-*.jar app.jar

# Ensure the app runs on 9090 inside the container
ENV SERVER_PORT=9090
EXPOSE 9090

ENTRYPOINT ["java", "-jar", "app.jar"]