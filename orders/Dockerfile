FROM maven:3-jdk-11 as build
WORKDIR /tmp

copy src /tmp/src
copy pom.xml /tmp/
RUN mvn clean package

#from adoptopenjdk/openjdk11:alpine

#COPY --from=build /tmp/target/orders.jar /orders.jar

#run chmod a+rx ./orders.jar

#USER ${SERVICE_USER}
#ENTRYPOINT ["/opt/java/openjdk/bin/java","-jar","./orders.jar", "--port=80"]

FROM weaveworksdemos/msd-java:latest

COPY --from=build /tmp/target/orders.jar /app.jar
#WORKDIR /usr/src/app
#COPY *.jar ./app.jar

RUN     chown -R ${SERVICE_USER}:${SERVICE_GROUP} ./app.jar

USER ${SERVICE_USER}

ENV JAVA_OPTS "-Djava.security.egd=file:/dev/urandom"
ENTRYPOINT ["/usr/local/bin/java.sh","-jar","./app.jar", "--port=80"]
