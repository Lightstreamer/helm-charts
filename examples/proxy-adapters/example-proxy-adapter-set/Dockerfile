FROM node
WORKDIR /app
COPY adapter.cjs /app

RUN set -eux; \
    cd /app; \
    npm install lightstreamer-adapter;

ENTRYPOINT ["node", "adapter.cjs"]
