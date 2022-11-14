FROM alpine:3.16.3 as build

ADD "https://www.random.org/cgi-bin/randbyte?nbytes=10&format=h" skip-cache-for-stage

# hadolint ignore=DL3018
RUN set -eux \
    && apk --no-cache add dnsmasq

FROM scratch as layout

COPY --from=build /lib/ld-musl-*.so.1 /lib/
COPY --from=build /lib/libc.musl-*.so.1 /lib/
COPY --from=build /usr/sbin/dnsmasq /usr/sbin/dnsmasq

FROM scratch as final

COPY --from=layout --chown=0:0 / /

# --port=0 to disable the DNS functionality
ENTRYPOINT [ "/usr/sbin/dnsmasq", "--keep-in-foreground", "--log-facility=-", "--user=", "--group=", "--pid-file" ]
