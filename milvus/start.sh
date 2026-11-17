#!/bin/sh
# Railway wrapper for Milvus standalone: prepares the volume and the two config
# files upstream's standalone_embed.sh bind-mounts, then runs Milvus as the
# image's non-root "milvus" user.
set -eu

DATA=/var/lib/milvus
mkdir -p "$DATA/etcd"

# Railway volumes are root-owned; the 3.x image runs as milvus (uid 999).
uid="$(id -u milvus)"; gid="$(id -g milvus)"
if [ "$(stat -c %u "$DATA")" != "$uid" ] || [ "$(stat -c %u "$DATA/etcd")" != "$uid" ]; then
  echo "railway-milvus: giving $DATA to milvus ($uid:$gid)"
  chown -R "$uid:$gid" "$DATA"
fi

cat > /milvus/configs/embedEtcd.yaml <<'YAML'
listen-client-urls: http://127.0.0.1:2379
advertise-client-urls: http://127.0.0.1:2379
quota-backend-bytes: 4294967296
auto-compaction-mode: revision
auto-compaction-retention: '1000'
YAML
[ -f /milvus/configs/user.yaml ] || printf '# Extra config to override default milvus.yaml\n' > /milvus/configs/user.yaml
chown "$uid:$gid" /milvus/configs/embedEtcd.yaml /milvus/configs/user.yaml

if [ -z "${COMMON_SECURITY_DEFAULTROOTPASSWORD:-}" ]; then
  echo "railway-milvus: COMMON_SECURITY_DEFAULTROOTPASSWORD is empty; refusing to start with the default root password" >&2
  exit 1
fi

# setpriv aborts in this image (jemalloc LD_PRELOAD); runuser keeps the environment.
exec runuser -u milvus -- milvus run standalone
