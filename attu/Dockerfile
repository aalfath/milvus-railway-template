# Attu, the official Milvus web UI, for Railway.
# Official image, pinned by version and digest. Bump both together.
FROM zilliz/attu:v3.0.2@sha256:34a06bf596ce11dca917b3aec7bd9c192a12f800110544c2243df623cb33d1b5

# Name and user of the pre-seeded Milvus connection (MILVUS_ADDRESS and
# MILVUS_PASSWORD come from Railway references to the Milvus service).
ENV MILVUS_NAME=Milvus \
    MILVUS_USERNAME=root \
    ATTU_AUTH_MODE=local

USER root
COPY --chmod=755 start.sh /usr/local/bin/railway-attu-start
EXPOSE 3000
ENTRYPOINT ["/usr/local/bin/railway-attu-start"]
CMD ["node", ".output/server/index.mjs"]
