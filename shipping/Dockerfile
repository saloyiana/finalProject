FROM bryandollery/maven-repo as build
WORKDIR /tmp

copy src /tmp/src
copy pom.xml /tmp/

run mvn clean package

#from adoptopenjdk/openjdk11:alpine

FROM weaveworksdemos/msd-java:latest

COPY --from=build /tmp/target/shipping*.jar /shipping.jar

run chmod a+rwx ./shipping.jar

USER ${SERVICE_USER}

ARG BUILD_DATE
ARG BUILD_VERSION
ARG COMMIT

LABEL org.label-schema.vendor="saloyiana" \
  org.label-schema.build-date="${BUILD_DATE}" \
  org.label-schema.version="${BUILD_VERSION}" \
  org.label-schema.name="Socks Shop: Shipping" \
  org.label-schema.description="REST API for Shipping service" \
  org.label-schema.url="https://github.com/microservices-demo/shipping" \
  org.label-schema.vcs-url="github.com:microservices-demo/shipping.git" \
  org.label-schema.vcs-ref="${COMMIT}" \
  org.label-schema.schema-version="1.0"

#ENTRYPOINT ["/opt/java/openjdk/bin/java","-jar","./shipping.jar", "--port=80"]

ENV JAVA_OPTS "-Djava.security.egd=file:/dev/urandom"

ENTRYPOINT ["/usr/local/bin/java.sh","-jar","./shipping.jar", "--port=80"]
