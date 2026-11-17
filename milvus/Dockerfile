# Milvus standalone (embedded etcd, local storage) for Railway.
# Official image, pinned by version and digest. Bump both together.
FROM milvusdb/milvus:v3.0.6@sha256:6c606011b3d9124487344b80434d98094624ef359e8a33715263fd1206772069

# Same settings as upstream's standalone_embed.sh (the official single-container install).
ENV ETCD_USE_EMBED=true \
    ETCD_DATA_DIR=/var/lib/milvus/etcd \
    ETCD_CONFIG_PATH=/milvus/configs/embedEtcd.yaml \
    COMMON_STORAGETYPE=local \
    DEPLOY_MODE=STANDALONE \
    COMMON_SECURITY_AUTHORIZATIONENABLED=true

USER root
COPY --chmod=755 start.sh /usr/local/bin/railway-milvus-start
EXPOSE 19530 9091
ENTRYPOINT ["/tini", "--", "/usr/local/bin/railway-milvus-start"]
