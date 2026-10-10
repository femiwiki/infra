# docker

The containers that serve the wiki. One host, `docker`, in `ap-northeast-2`.

This root was `docker-seoul` while Tokyo still served, duplicating a Tokyo root
so that a change to one could not replace the other's containers. Tokyo was
retired on 2026-09-27 and that root went with it; this one took the name in
femiwiki/infra#942.

The serving configuration is not here: `FW_CADDYFILE`, `FW_ROBOTS_TXT` and
`MEDIAWIKI_HOTFIX_SNIPPET` render `../serving`, which is why a change there
needs `fastcgi_generation` moved with it (femiwiki/infra#783).

The `http` container keeps the ACME account and certificates under
`caddycerts/` in the `caddy_certs` bucket of `aws/`, in the same region.

This host runs cron. `backupbot` is in no root: the dump runs on the database
host from a systemd timer, to `backups-302617221463-ap-northeast-2-an`.

## Replacing a container

`image` and the whole `env` block are create-only in the docker provider, so any
change to either replaces the container. The names carry
`${local.fastcgi_generation}` and the ports alternate on its parity, so the
generation moves with every such change; `.github/actions/generation-swaps-ports`
refuses a number that would collide with what is running.

## When a new generation fails

**The apply failed and the old generation still serves.** A `fastcgi-N` whose
warm-up keeps getting server errors stops its own php-fpm and never turns
healthy, so the apply fails after `wait_timeout` and `fastcgi-(N-1)` keeps
serving. Nothing needs rolling back. Read `fastcgi-N`'s log for the cause, push
the fix to the same pull request with `fastcgi_generation` at N+2, and approve
again. `generation-swaps-ports` names that number, and the apply removes both
older fastcgi containers.

**The apply succeeded and the new generation serves errors.** Put the previous
image back from a branch, without waiting for a pull request's checks:

```sh
git switch -c rollback-<N+1> origin/main
git revert --no-commit <the bump's commit>   # the previous image tag
hcledit attribute set locals.fastcgi_generation <N+1> -f docker/locals.tf -u
git commit -m 'revert: roll docker back to <previous tag>'
git push -u origin rollback-<N+1>
gh workflow run tofu.yml -R femiwiki/infra --ref rollback-<N+1> -f workspace=docker
```

The `docker apply` deployment of that run waits for its environment. Approving
it applies the branch with no plan to read first. Then open a pull request from
the branch, so main describes what serves again; its docker plan is empty. If
`serving/` changed after the bump, revert that commit too, since the older image
may not load the newer file.
