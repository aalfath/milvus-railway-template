[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/new/template/milvus-2?utm_medium=integration&utm_source=button&utm_campaign=milvus)

# Milvus on Railway

The source of the [Milvus Railway template](https://railway.com/deploy/milvus-2). Milvus is an open-source vector database for similarity search over embeddings ([milvus-io/milvus](https://github.com/milvus-io/milvus), Apache-2.0).

## What it deploys

| Service | Folder | Image (pinned by version and digest) | Volume | Public |
|---|---|---|---|---|
| `Milvus` | `milvus/` | `milvusdb/milvus:v3.0.6` | `/var/lib/milvus` | HTTPS domain to port 19530 (REST v2 API) |
| `Attu` | `attu/` | `zilliz/attu:v3.0.2` | `/data` | HTTPS domain (web UI) |

- **Milvus** runs in standalone mode with embedded etcd and local storage. This is the same single-container setup as upstream's [`standalone_embed.sh`](https://github.com/milvus-io/milvus/blob/v3.0.6/scripts/standalone_embed.sh), so metadata, the write-ahead log and segments all live on the one volume. Authentication is always on. The wrapper refuses to start without a root password, prepares the volume for the image's non-root `milvus` user, and writes the embedded etcd config.
- **Attu** is the official Milvus web UI. Its login is on, the admin account is created from a generated password on first boot, and a connection to Milvus over Railway's private network is pre-seeded. Attu has been closed source since v2.6 (free to use as the official image). Milvus itself is Apache-2.0.

## Variables

| Service | Variable | Default | What it is |
|---|---|---|---|
| Milvus | `COMMON_SECURITY_DEFAULTROOTPASSWORD` | `${{secret(32)}}` | Password of the Milvus `root` user. Applied on the first boot only. |
| Milvus | `PORT` | `9091` | Milvus health and metrics port, used by Railway's health check. It is private, not public. |
| Attu | `ATTU_ADMIN_USER` | `admin` | Attu admin user, created on the first boot. |
| Attu | `ATTU_ADMIN_PASSWORD` | generated, 48 characters | Attu admin password, used on the first boot only. |
| Attu | `MILVUS_ADDRESS` | `${{Milvus.RAILWAY_PRIVATE_DOMAIN}}:19530` | The Milvus endpoint that Attu's pre-seeded connection uses. |
| Attu | `MILVUS_PASSWORD` | `${{Milvus.COMMON_SECURITY_DEFAULTROOTPASSWORD}}` | Password for the pre-seeded connection. |
| Attu | `PORT` | `3000` | The Attu web port. |

Nothing has to be filled in when you deploy.

## Connecting

- **From another Railway service in the same project:** URI `http://${{Milvus.RAILWAY_PRIVATE_DOMAIN}}:19530`, token `root:${{Milvus.COMMON_SECURITY_DEFAULTROOTPASSWORD}}`. This works for gRPC SDKs (pymilvus, Node, Go, Java) and for REST.
- **From outside Railway (REST v2):** `https://YOUR-MILVUS-DOMAIN/v2/vectordb/...` with the header `Authorization: Bearer root:YOUR-PASSWORD`.
- **gRPC SDKs from outside Railway:** add a TCP proxy to port 19530 on the Milvus service. That traffic is not encrypted, so use it only for testing.
- Change the root password in Attu or through the Milvus API. Changing the variable after the first boot has no effect on the stored password, and Attu's connection then needs the new password too.

## Updates

Railway tells deployers when this repo's `main` branch changes. Each bump changes the `FROM` pin (version and digest) and adds a `CHANGELOG.md` entry, with breaking changes first. Back up the Milvus volume before a major upgrade, because Milvus upgrades are one-way.

## Local test

```sh
docker build -t milvus-rt milvus && docker build -t attu-rt attu
```

Run both with the variables above. Use a container network, and point `MILVUS_ADDRESS` at the Milvus container on port 19530.
