FROM alpine:latest as build

WORKDIR /tmp
RUN apk add --no-cache --update --virtual .wget wget \
    && wget https://github.com/rfc1036/whois/archive/next.zip --no-check-certificate \
    && unzip /tmp/next.zip && rm -rf /tmp/next.zip && apk del .wget

WORKDIR /tmp/whois-next
ENV LIBS="-L/usr/lib -lintl"

RUN apk add --no-cache --update build-base wget perl unzip gettext-dev
RUN make CFLAGS="-DHAVE_GETOPT_LONG -DHAVE_GETADDRINFO -DHAVE_SHA_CRYPT" \
    && make install && cd /tmp \
    && rm -rf /tmp/whois-next
RUN grep "whois" /etc/services > /tmp/services


FROM scratch

COPY --from=build /usr/bin/whois /usr/local/bin/whois
COPY --from=build /usr/lib/libintl.so.8 /usr/lib/libintl.so.8
COPY --from=build /lib/ld-musl-x86_64.so.1 /lib/ld-musl-x86_64.so.1
COPY --from=build /tmp/services /etc/services


ENTRYPOINT ["/usr/local/bin/whois"]
