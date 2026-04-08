# Build stage: clone and compile the quickstart producer
FROM gradle:8-jdk21 AS build
RUN git clone --depth 1 --filter=blob:none --sparse \
      https://github.com/Lightstreamer/Lightstreamer-kafka-connector.git /build && \
    cd /build && \
    git sparse-checkout set examples/quickstart-producer && \
    cd examples/quickstart-producer && \
    ./gradlew build

# Runtime stage
FROM eclipse-temurin:21-jre
COPY --from=build \
  /build/examples/quickstart-producer/build/libs/quickstart-producer-*-all.jar \
  /usr/app/producer.jar
ENTRYPOINT ["java", "-jar", "/usr/app/producer.jar"]
