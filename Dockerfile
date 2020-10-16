FROM openjdk:15-jdk-alpine as build
WORKDIR /workspace/app

# single copy...?
COPY mvnw .
COPY .mvn .mvn
COPY pom.xml .
COPY src src

# cache...?
RUN /workspace/app/mvnw install -DskipTests

RUN mkdir -p target/dependency && (cd target/dependency; jar -xf /workspace/app/target/*.jar)
#RUN mkdir -p target/dependency && (cd target/dependency; java -Djarmode=layertools -jar /workspace/app/target/*.jar extract)

FROM openjdk:15-jdk-alpine
#FROM adoptopenjdk:11-jre-hotspot
ARG DEPENDENCY=/workspace/app/target/dependency
#COPY --from=builder ${DEPENDENCY}/dependencies/ ./
#COPY --from=builder ${DEPENDENCY}/spring-boot-loader/ ./
#COPY --from=builder ${DEPENDENCY}/snapshot-dependencies/ ./
#COPY --from=builder ${DEPENDENCY}/application/ ./
#ENTRYPOINT ["java", "org.springframework.boot.loader.JarLauncher"]
COPY --from=build ${DEPENDENCY}/BOOT-INF/lib /app/lib
COPY --from=build ${DEPENDENCY}/META-INF /app/META-INF
COPY --from=build ${DEPENDENCY}/BOOT-INF/classes /app
ENTRYPOINT ["java","-cp","app:app/lib/*","com.example.tekton.TektonApplication"]
