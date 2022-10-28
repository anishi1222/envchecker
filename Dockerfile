ARG BUILD_IMAGE=maven:3.8.6-eclipse-temurin-17-focal
ARG RUNTIME_IMAGE=mcr.microsoft.com/openjdk/jdk:17-ubuntu

#ARG PROXY_SET=false
#ARG PROXY_HOST=
#ARG PROXY_PORT=

# ---------------------------------------------------
# Resolve all maven dependencies
# ---------------------------------------------------
FROM ${BUILD_IMAGE} as dependencies

COPY pom.xml ./

RUN mvn -B dependency:go-offline
#        -DproxySet=${PROXY_SET} \
#        -DproxyHost=${PROXY_HOST} \
#        -DproxyPort=${PROXY_PORT} \

# ---------------------------------------------------
# Build an artifact
# ---------------------------------------------------
FROM dependencies as build

COPY src ./src

RUN mvn -B clean package -Dmaven.test.skip
#        -DproxySet=${PROXY_SET} \
#        -DproxyHost=${PROXY_HOST} \
#        -DproxyPort=${PROXY_PORT} \

# ---------------------------------------------------
# Build container
# ---------------------------------------------------
FROM ${RUNTIME_IMAGE}

RUN mkdir /opt/app
COPY --from=build /target/illuminate4micronaut-0.1.jar /opt/app/illuminate4micronaut.jar
# COPY --from=build /target/libs /opt/app/libs
COPY applicationinsights.json /opt/app/applicationinsights.json
COPY applicationinsights-agent-illuminate-3.4.1.jar /opt/app/applicationinsights-agent-illuminate-3.4.1.jar
EXPOSE 8080
ENTRYPOINT ["java","-XX:+UseG1GC","-javaagent:/opt/app/applicationinsights-agent-illuminate-3.4.1.jar","-jar", "/opt/app/illuminate4micronaut.jar"]
