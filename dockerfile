# Stage 1: Build
FROM eclipse-temurin:17-jdk-alpine AS build
WORKDIR /app

# Copy only Maven wrapper and POM first to cache dependencies
COPY pom.xml mvnw ./
COPY .mvn .mvn

# Make sure mvnw is executable (important for Alpine)
RUN chmod +x mvnw

# Download dependencies without building
RUN ./mvnw dependency:go-offline

# Copy only source code now
COPY src ./src

# Build the application
RUN ./mvnw clean package -DskipTests

# Stage 2: Run
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app

# Copy the JAR from the build stage
COPY --from=build /app/target/jenkins-0.0.1-SNAPSHOT.jar app.jar
# Expose port 9090
EXPOSE 9090

# Run the application
ENTRYPOINT ["java", "-jar", "app.jar"]