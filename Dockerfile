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

# Add the DataDog Java agent directly from the URL
ADD https://dtdg.co/latest-java-tracer /app/dd-java-agent.jar

# Copy over the built artifact from the builder stage
COPY --from=builder /app/build/libs/*.jar /app/app.jar

# Expose port 8080 to the outside world
EXPOSE 8080

# Use shell form to enable environment variable resolution at runtime
ENTRYPOINT ["sh", "-c", "export DD_AGENT_HOST=$(curl http://169.254.169.254/latest/meta-data/local-ipv4) && java -javaagent:/app/dd-java-agent.jar -jar /app/app.jar"]
