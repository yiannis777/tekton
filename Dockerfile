FROM openjdk:15-jdk-alpine as builder
#FROM adoptopenjdk:11-jre-hotspot as builder
WORKDIR /workspace/app

COPY mvnw .
COPY .mvn .mvn
COPY pom.xml .
COPY src src

RUN /workspace/app/mvnw install -DskipTests

ARG JAR_FILE=target/*.jar
COPY ${JAR_FILE} application.jar
RUN java -Djarmode=layertools -jar application.jar extract

FROM openjdk:15-jdk-alpine
#FROM adoptopenjdk:11-jre-hotspot
WORKDIR /workspace/app
COPY --from=builder /workspace/app/dependencies/ ./
COPY --from=builder /workspace/app/spring-boot-loader/ ./
COPY --from=builder /workspace/app/snapshot-dependencies/ ./
COPY --from=builder /workspace/app/application/ ./
ENTRYPOINT ["java", "org.springframework.boot.loader.JarLauncher"]