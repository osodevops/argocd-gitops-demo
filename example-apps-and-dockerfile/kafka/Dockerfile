# Use Maven to build the application
FROM maven:3.8.1-openjdk-11 AS build
WORKDIR /app
COPY pom.xml .
COPY src ./src
RUN mvn clean package

# Use a minimal base image to run the application
FROM openjdk:11-jre-slim
WORKDIR /app
COPY --from=build /app/target/kafka-app-1.0-SNAPSHOT.jar kafka-app.jar
ENTRYPOINT ["java", "-jar", "kafka-app.jar"]
