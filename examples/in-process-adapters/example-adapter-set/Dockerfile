FROM lightstreamer

# Copy the adapter deployment files to the Lightstreamer adapters directory
COPY build/libs/example-adapter-set-1.0.0.jar /lightstreamer/adapters/example-adapter-set/lib/

# Copy the test page to the Lightstreamer pages directory
COPY index.html /lightstreamer/pages/index.html

# Install jq for the readiness probe. The probe issued by the chart pipes
# the response of the `/lightstreamer/readiness_check` endpoint into the
# custom script bundled in the readiness-script ConfigMap, and the sample
# script uses jq to parse the JSON body. jq is not present in the base
# Lightstreamer image.
USER root
RUN set -eux; \
        apt-get update; \
        apt-get install -y --no-install-recommends jq
USER lightstreamer
