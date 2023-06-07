FROM alpine:latest
RUN apk add --no-cache bash curl jq
RUN apk add --update curl && \
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
    install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl && \
    rm kubectl && \
    apk del curl && \
    rm -rf /var/cache/apk/*
COPY ./kubesphere.sh /app/kubesphere.sh
WORKDIR /app
CMD ["/bin/bash", "/app/kubesphere.sh"]

