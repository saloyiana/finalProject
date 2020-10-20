FROM maven:3-jdk-11 as build
WORKDIR /tmp

copy src /tmp/src
copy pom.xml /tmp/
RUN mvn clean package

from adoptopenjdk/openjdk11:alpine

COPY --from=build /tmp/target/orders.jar /orders.jar

run chmod a+rx ./orders.jar

USER ${SERVICE_USER}
ENTRYPOINT ["/opt/java/openjdk/bin/java","-jar","./orders.jar", "--port=80"]

