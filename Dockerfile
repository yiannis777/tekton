FROM openjdk:15-jdk-alpine as builder
WORKDIR /workspace/app

# single copy...?
COPY mvnw .
COPY .mvn .mvn
COPY pom.xml .
COPY src src

# cache...?
RUN /workspace/app/mvnw install -DskipTests

#RUN mkdir -p target/dependency && (cd target/dependency; java -Djarmode=layertools -jar /workspace/app/target/*.jar extract)
RUN java -Djarmode=layertools -jar /workspace/app/target/*.jar extract

FROM openjdk:15-jdk-alpine
#FROM adoptopenjdk:11-jre-hotspot
#ARG DEPENDENCY=/workspace/app/target/dependency
COPY --from=builder /workspace/app/target/dependencies/ ./
COPY --from=builder /workspace/app/target/spring-boot-loader/ ./
COPY --from=builder /workspace/app/target/snapshot-dependencies/ ./
COPY --from=builder /workspace/app/target/application/ ./
ENTRYPOINT ["java", "org.springframework.boot.loader.JarLauncher"]
