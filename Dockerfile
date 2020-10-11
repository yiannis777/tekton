FROM openjdk:15-jdk-alpine as builder
WORKDIR /workspace/app

COPY mvnw .
COPY .mvn .mvn
COPY pom.xml .
COPY src src

RUN /workspace/app/mvnw install -DskipTests

ARG JAR_FILE=/workspace/app/target/*.jar
COPY ${JAR_FILE} /workspace/app/application.jar

RUN mkdir -p target/dependency && (cd target/dependency; java -Djarmode=layertools -jar /workspace/app/application.jar extract)

FROM openjdk:15-jdk-alpine
#FROM adoptopenjdk:11-jre-hotspot
ARG DEPENDENCY=/workspace/app/target/dependency
COPY --from=builder ${DEPENDENCY}/dependencies/ ./
COPY --from=builder ${DEPENDENCY}/spring-boot-loader/ ./
COPY --from=builder ${DEPENDENCY}/snapshot-dependencies/ ./
COPY --from=builder ${DEPENDENCY}/application/ ./
ENTRYPOINT ["java", "org.springframework.boot.loader.JarLauncher"]
