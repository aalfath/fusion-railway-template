# Fusion, a lightweight self-hosted RSS reader: https://github.com/0x2E/fusion
# Official image, pinned by version and digest (multi-arch index).
FROM ghcr.io/0x2e/fusion:1.3.1@sha256:e1a7410d8b424e7a5f2195a858900291e138d99211eb2f12553627ed48c66fe2

COPY --chmod=755 railway-start.sh /usr/local/bin/railway-start.sh

# Upstream reads PORT as a fallback for FUSION_PORT; Railway sets PORT.
ENV FUSION_DB_PATH=/data/fusion.db
EXPOSE 8080

ENTRYPOINT ["/usr/local/bin/railway-start.sh"]
