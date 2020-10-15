FROM openjdk:15-jdk-alpine as builder
WORKDIR /workspace/app

# single copy...?
COPY mvnw .
COPY .mvn .mvn
COPY pom.xml .
COPY src src

# cache...?
RUN /workspace/app/mvnw install -DskipTests

RUN mkdir -p target/dependency && (cd target/dependency; java -Djarmode=layertools -jar ../*.jar extract)

FROM openjdk:15-jdk-alpine
#FROM adoptopenjdk:11-jre-hotspot
ARG DEPENDENCY=/workspace/app/target/dependency
COPY --from=builder ${DEPENDENCY}/dependencies/ ./
COPY --from=builder ${DEPENDENCY}/spring-boot-loader/ ./
COPY --from=builder ${DEPENDENCY}/snapshot-dependencies/ ./
COPY --from=builder ${DEPENDENCY}/application/ ./
ENTRYPOINT ["java", "org.springframework.boot.loader.JarLauncher"]
