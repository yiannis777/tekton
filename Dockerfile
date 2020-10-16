# syntax=docker/dockerfile:experimental
FROM openjdk:15-jdk-alpine as build
WORKDIR /workspace/app

#RUN addgroup -S demo && adduser -S demo -G demo
#USER demo

COPY mvnw .
COPY .mvn .mvn
COPY pom.xml .
COPY src src

#RUN --mount=type=cache,target=/root/.m2 /workspace/app/mvnw install -DskipTests
RUN /workspace/app/mvnw install -DskipTests

#RUN mkdir -p target/dependency && (cd target/dependency; jar -xf /workspace/app/target/*.jar)
RUN mkdir -p target/dependency && (cd target/dependency; java -Djarmode=layertools -jar /workspace/app/target/*.jar extract)

FROM openjdk:15-jdk-alpine
#FROM adoptopenjdk:11-jre-hotspot
ARG DEPENDENCY=/workspace/app/target/dependency

COPY --from=build ${DEPENDENCY}/dependencies/ ./
COPY --from=build ${DEPENDENCY}/spring-boot-loader/ ./
COPY --from=build ${DEPENDENCY}/snapshot-dependencies/ ./
COPY --from=build ${DEPENDENCY}/application/ ./
ENTRYPOINT ["java", "org.springframework.boot.loader.JarLauncher"]

#COPY --from=build ${DEPENDENCY}/BOOT-INF/lib /app/lib
#COPY --from=build ${DEPENDENCY}/META-INF /app/META-INF
#COPY --from=build ${DEPENDENCY}/BOOT-INF/classes /app
#ENTRYPOINT ["java","-cp","app:app/lib/*","com.example.tekton.TektonApplication"]
