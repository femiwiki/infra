# Femiwiki Infra

[![Github checks Status]][github checks link]

Terraform code that defines FemiWiki's infrastructure. The workspaces are
`aws/`, `docker/`, `gcp/`, `github/`, `grafana/`, `healthchecks/` and
`mariadb/`. All of them run on [OpenTofu] and keep their state in S3.

## Applying

Every workspace is applied through a PR. [terraform-github-tacos] handles the
plan, approval, apply and merge, and its [Apply-before-merge] page describes the
flow of applying before merging. The Docker daemon for `docker/` listens only on
the edge box's loopback, so the workflow connects through an SSM tunnel, and
`mariadb/` reaches MariaDB on the database host the same way. When a PR is
opened, `.github/workflows/tofu.yml` comments the plan. If the plan has changes,
the `<workspace> apply` job of the same run waits for approval in the GitHub
environment of that name, and approving it under Review deployments on the run
page applies that plan. Image bump PRs follow the same flow. Pushing a new
commit cancels the previous run's pending approval, and the new run waits for
approval again.

[dflook/tofu-apply] writes the result in the status line at the bottom of the
plan comment: 🟠 means applying, ✅ means applied, and ❌ means not applied or
failed. Workflow run logs are deleted after a while, so once an apply finishes,
the apply log of each workspace is left as a PR comment.

Merging comes after that. The required check `tofu gate` reports only after the
apply waiting for approval has finished, so a PR that has not been applied
cannot be merged. When the apply succeeds, the workflow merges the PR, so there
is nothing else to do after applying.

When an apply finishes in any workspace, the ` ```wikitext ` block in that PR's
body is posted as is to [페미위키:업데이트], under a heading with the time the
apply finished (to the minute). It has to go on this page itself, not on a
yearly subpage, for FediFeeds to publish new sections in the same feed, so at
the turn of each year last year's sections are cut and moved by hand to
`페미위키:업데이트/<year>년` (moving the page is not an option because the page
ID moves with it). Inside the block, put lines starting with `*` under category
headings such as `===feat===`, `===fix===`, `===perf===` or `===보안 패치===`,
or prefix a line with its category, like `(내부 변화) `. A category on the line
wins over the heading. When posting, feat becomes 추가, fix becomes 수정, perf
becomes 성능 개선, and any other English type becomes 내부 변화, in the order
추가, 수정, 성능 개선, 보안 패치, 내부 변화, 버그. A single item becomes one
`(category) …` line; five or more items in two or more categories become one
section per category; anything else becomes a `*(category) …` list. Bot lines
lose their `(name hash)`, the period before the link, and the `#N` link text. If
you edit the PR body before it is posted, the edited text is posted.
docker-mediawiki carries the blocks of its own PRs over to the image bump PR.
PRs outside `docker/` get no block automatically, so add one yourself for
changes readers would notice. A PR without a block posts nothing, and a block
already on the page is not posted again. The bot account is the repository
variable `WIKI_DEPLOY_BOT_USER` with the secret `WIKI_DEPLOY_BOT_PASSWORD`. If
either is missing, the posting step is skipped. If this step fails because the
wiki is not responding or is read-only, the deploy still counts as successful,
and the run gets an error annotation and a one-line summary on how to post
again. For a PR that is already applied, add or fix the block in its body, then
run the `post update` workflow with the PR number. If the apply time is left
empty, the merge time is used as the heading, and the items go in their place in
time order.

[페미위키:업데이트]: https://femiwiki.com/w/페미위키:업데이트

## Editing `.tf` files

When editing `.tf` files with a script, use [hcledit] to address attributes or
blocks instead of `sed` or string replacement. Run `tofu fmt` afterwards.

```sh
hcledit attribute set locals.schema_update_generation 145 -f docker/locals.tf -u
hcledit attribute get locals.femiwiki_image -f docker/locals.tf
hcledit block list -f github/repo.tf
```

## Collector configuration on the hosts

The OpenTelemetry Collector sends metrics, logs and profiles from both hosts to
Grafana Cloud. The configuration is a single file,
`aws/res/config.otelcol.yaml.tftpl`, and the parts only the app host has are
split off with `%{ if type == "app" ~}`.

SSM State Manager is what actually pushes the configuration. Applying `aws/`
runs the `install-otelcol-docker` and `install-otelcol-database` associations
once right away, and again every 30 minutes after that, which also reverts any
manual edits. `user_data` is under `ignore_changes`, so it does not touch
running hosts; a newly created instance runs the same script once at boot.

`aws/res/install-otelcol.sh` installs pinned versions of the Collector and
node_exporter, reads the Grafana credentials from SecureString parameters under
`/alloy/` in Parameter Store, and writes them to `/etc/otelcol-contrib`. The
configuration file holds no passwords; the Collector reads that file with
`${file:...}`. It reloads only when the content has changed.

## Adding a workspace

Every workspace shares one `tofu.yml` for plan and apply. A new workspace needs
the following.

1. A `<name>/` directory and the S3 backend key `<name>/terraform.tfstate`
2. An `infra-<name>` role in `aws/iam.tf` that can read the state bucket. The
   `sub` in its trust policy has two values, `pull_request` and
   `environment:<name>`
3. A GitHub environment of the same name. Adding it to `module.tacos` in
   `github/repo.tf` also attaches the required reviewers. An environment
   without reviewers would apply without asking anyone, so the workflow
   refuses it
4. `<name>` in the `workflow_dispatch` choices (`&workspaces`) of `tofu.yml`.
   The plan's `matrix` uses the same list, and apply only applies the
   workspaces whose plan has changes. Also add it to the `case()` for the
   Discord webhook, and any `TF_VAR_*` if it has variables

`tofu gate` is the only required check, so branch protection does not change.

To run it by hand you need the AWS CLI and the [Session Manager plugin].

```bash
# Terminal 1: the tunnel. The daemon only opens a Unix socket, so forward it
# with ssh over SSM
instance=$(aws ec2 describe-instances \
  --filters Name=tag:Name,Values=docker Name=instance-state-name,Values=running \
  --query 'Reservations[].Instances[].InstanceId' --output text)
ssh-keygen -q -t ed25519 -N '' -f /tmp/docker-key
aws ec2-instance-connect send-ssh-public-key --instance-id "$instance" \
  --instance-os-user ec2-user --ssh-public-key file:///tmp/docker-key.pub
ssh -N -i /tmp/docker-key \
  -o 'ProxyCommand=aws ssm start-session --target %h --document-name AWS-StartSSHSession --parameters portNumber=%p' \
  -L 127.0.0.1:2376:/var/run/docker.sock "ec2-user@$instance"

# Terminal 2
tofu -chdir=docker init
tofu -chdir=docker plan
tofu -chdir=docker apply
```

[github checks status]: https://badgen.net/github/checks/femiwiki/infra
[github checks link]: https://github.com/femiwiki/infra/actions
[Session Manager plugin]: https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html
[OpenTofu]: https://opentofu.org
[hcledit]: https://github.com/minamijoyo/hcledit
[terraform-github-tacos]: https://github.com/femiwiki/terraform-github-tacos
[Apply-before-merge]: https://femiwiki.github.io/terraform-github-tacos/Apply-before-merge
[dflook/tofu-apply]: https://github.com/dflook/terraform-github-actions/tree/main/tofu-apply
