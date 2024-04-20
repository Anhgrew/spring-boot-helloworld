# Start with a base image containing Java runtime
FROM openjdk:8-jdk-alpine as builder

# Set the working directory in the container
WORKDIR /app

# Copy the local Gradle Wrapper, build file, and source code to the container
COPY gradlew .
COPY gradle gradle
COPY build.gradle .
COPY src src

# Provide necessary permissions for the Gradle Wrapper
RUN chmod +x ./gradlew

# Build the application using the Gradle Wrapper without running tests
RUN ./gradlew build -x test --no-daemon

# Use a lightweight base image for the final stage to keep the container small
FROM openjdk:8-jre-alpine

# Set the working directory in the container
WORKDIR /app

# Copy over the built artifact from the builder stage
COPY --from=builder /app/build/libs/*.jar /app/app.jar

# Expose port 8080 to the outside world
EXPOSE 8080

# Run the application
ENTRYPOINT ["java", "-jar", "/app/app.jar"]
