FROM alpine:latest
RUN apk add --no-cache bash curl jq
COPY ./kubesphere.sh /app/kubesphere.sh
WORKDIR /app
CMD ["/bin/bash", "/app/kubesphere.sh"]
