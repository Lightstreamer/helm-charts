FROM node
WORKDIR /app
COPY helloworld.cjs /app

RUN set -eux; \
    cd /app; \
    npm install lightstreamer-adapter;

ENTRYPOINT ["node", "helloworld.cjs"]
