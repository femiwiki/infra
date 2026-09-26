# docker-seoul

The containers on the Seoul host, for as long as there are two regions.

This root exists only for the Tokyo to Seoul migration. It duplicates
`../docker` because a second `provider "docker"` in that root would mean every
change to Seoul applies to production Tokyo, and because a shared
`fastcgi_generation` would make a Tokyo deploy replace Seoul's containers. The
serving configuration is not duplicated: both roots render `../serving`.

It differs from `../docker` in two places, and only these two:

| | |
|---|---|
| `AWS_REGION` on `fastcgi` | `ap-northeast-2`, the region chamber reads |
| `WG_BOUNCE_HANDLER_INTERNAL_IPS` | `10.20.0.0/16` |

`MEDIAWIKI_SKIP_CRON` used to be here and is now in `../docker` instead: this
host runs cron, and the Tokyo one, which serves only the stragglers of the DNS
tail, does not. Two cron hosts double-run every job. `backupbot` is in neither
root any more, because the dump runs on the database host from a systemd timer.

`AWS_REGION` and `S3_HOST` in the `http` container still name `ap-northeast-1`.
They address the bucket holding the ACME account and certificates, which both
regions share, and that bucket is in Tokyo.

## When Tokyo is retired

These go together. Leaving any one behind breaks something quietly.

1. `docker-seoul plan is empty` comes out of `required_status_checks_contexts`
   in `../github/repo.tf`. A required check that nothing reports blocks every
   pull request; this happened once already, in femiwiki/infra#827.
2. `docker-seoul` comes out of the `&workspaces` anchor in
   `../.github/workflows/tofu.yaml`.
3. This directory is deleted and `../docker` becomes Seoul's, or this directory
   is renamed to `docker` and the Tokyo one is deleted. Renaming inherits the
   existing required check, which is why it is the simpler of the two.
4. `aws_iam_role.infra_docker_seoul` and its policy go from `../aws`.
5. `github_repository_environment.infra_docker_seoul` goes from
   `../github/repo.tf`.
