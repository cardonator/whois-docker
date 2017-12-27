FROM alpine:latest

WORKDIR /tmp
RUN apk add --no-cache --update --virtual .wget wget \
    && wget https://github.com/rfc1036/whois/archive/next.zip --no-check-certificate \
    && unzip /tmp/next.zip && rm -rf /tmp/next.zip && apk del .wget

WORKDIR /tmp/whois-next
ENV LIBS="-L/usr/lib -lintl"
RUN apk add --no-cache --update --virtual .build-deps build-base wget perl unzip \
    && apk add --no-cache --update gettext-dev \
    && make CFLAGS="-DHAVE_GETOPT_LONG -DHAVE_GETADDRINFO -DHAVE_SHA_CRYPT" && make install && cd /tmp && rm -rf /tmp/whois-next \
    && apk del .build-deps

ENTRYPOINT [ "/bin/sh" ]
