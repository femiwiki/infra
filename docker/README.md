# docker

The containers that serve the wiki. One host, `docker`, in `ap-northeast-2`.

This root was `docker-seoul` while Tokyo still served, duplicating a Tokyo root
so that a change to one could not replace the other's containers. Tokyo was
retired on 2026-09-27 and that root went with it; this one took the name in
femiwiki/infra#942.

The serving configuration is not here: `FW_CADDYFILE`, `FW_ROBOTS_TXT` and
`MEDIAWIKI_HOTFIX_SNIPPET` render `../serving`, which is why a change there
needs `fastcgi_generation` moved with it (femiwiki/infra#783).

`AWS_REGION` and `S3_HOST` in the `http` container still name `ap-northeast-1`.
They address `femiwiki-secrets`, which holds the ACME account and certificates
under `caddycerts/`, and that bucket is in Tokyo. It is the reason
`ap-northeast-1` is not empty even with no instance in it.

This host runs cron. `backupbot` is in no root: the dump runs on the database
host from a systemd timer, to `backups-302617221463-ap-northeast-2-an`.

## Replacing a container

`image` and the whole `env` block are create-only in the docker provider, so any
change to either replaces the container. The names carry
`${local.fastcgi_generation}` and the ports alternate on its parity, so the
generation moves with every such change; `.github/actions/generation-swaps-ports`
refuses a number that would collide with what is running.
