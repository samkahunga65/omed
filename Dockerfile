FROM maven:3.9.9-eclipse-temurin-24-alpine AS build
LABEL authors="kahunga"
WORKDIR /app

# Copy Maven descriptor and download dependencies first (better caching)
COPY pom.xml .
RUN mvn -B dependency:resolve dependency:resolve-plugins

# Copy source and build the jar
COPY src ./src
RUN mvn -B package -DskipTests

# ---- runtime stage ----
FROM eclipse-temurin:24-jre-alpine
WORKDIR /app

# Copy only the built jar
COPY --from=build /app/target/*.jar app.jar

# Run as non-root user for safety
RUN addgroup -S app && adduser -S app -G app
USER app

# Run the application
ENTRYPOINT ["java", "-jar", "app.jar"]