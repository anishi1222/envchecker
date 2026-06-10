ARG BUILD_IMAGE=maven:3.9.16-eclipse-temurin-25
# ARG RUNTIME_IMAGE=mcr.microsoft.com/openjdk/jdk:25-distroless
ARG RUNTIME_IMAGE=mcr.microsoft.com/openjdk/jdk:25-azurelinux

#ARG PROXY_SET=false
#ARG PROXY_HOST=
#ARG PROXY_PORT=

# ---------------------------------------------------
# Resolve all maven dependencies
# ---------------------------------------------------
FROM ${BUILD_IMAGE} AS build

COPY pom.xml ./
COPY src ./src

RUN mvn -B clean dependency:copy-dependencies -DoutputDirectory=./target/lib package -Dmaven.test.skip

# ---------------------------------------------------
# Build container
# ---------------------------------------------------
FROM ${RUNTIME_IMAGE}
USER app
WORKDIR /opt/app
COPY --from=build /target/envchecker-0.1.jar app.jar
EXPOSE 8080
# CMD ["-XX:+UseParallelGC","-XX:MaxRAMPercentage=75","-XX:InitialRAMPercentage=75","-XX:+UseStringDeduplication", "-jar", "app.jar"]
CMD ["jaz", "-jar", "app.jar"]
