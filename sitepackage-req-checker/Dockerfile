FROM debian:bullseye-slim

RUN apt-get update -yqq && \
    apt-get install jq -yqq

COPY --chown=root:root --chmod=775 sitepackage-req-checker.sh /usr/local/bin/sitepackage-req-checker.sh

WORKDIR /app

ENTRYPOINT [ "/usr/local/bin/sitepackage-req-checker.sh" ]
CMD [""]

# manual usage: docker run -v ./:/app -it sitepackage-req-checker packages/xima_sitepackage/composer.json
