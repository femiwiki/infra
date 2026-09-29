---
name: femiwiki-deploy-watch
description: Watch a femiwiki deploy end to end — assert a branch is current before asking for an apply approval, follow the image-build and bump-PR chain, probe across the container swap, and verify afterwards. Use for any femiwiki/infra apply or femiwiki/docker-mediawiki image change.
---

# Watching a femiwiki deploy

Deploys here are a chain, and each link has a way of failing quietly. Follow the
whole chain rather than the step in front of you.

```text
docker-mediawiki PR merged
  -> image build (images.yml)
  -> infra bump PR opens by itself on branch bump-femiwiki-image
  -> its run plans, then 'docker apply' waits for the docker environment
  -> operator approves the deployment
  -> Actions applies, re-plans in place, merges the PR itself
  -> containers swap, generation + 1
```

The three checks that have been skipped before are a script, not prose:
`.claude/skills/femiwiki-deploy-watch/fw-deploy`, with the subcommands
`preflight`, `watch-apply` and `verify`. Run it; the prose below is only why each
gate is there. The paths below are relative to a femiwiki/infra checkout, which
is where this skill lives, so that a change to `.github/workflows/tofu.yaml` and
the skill that describes it can land in one pull request.

## Before asking for an apply, run the preflight

```sh
.claude/skills/femiwiki-deploy-watch/fw-deploy preflight <pr>
```

It prints a verdict word per gate and exits non-zero if any gate fails, so no
apply can be asked for on a pull request it refused. Both gates exist because
their prose version was read and not followed.

**Freshness.** The `scope` job refuses a pull request that is behind its base,
because a plan from a stale branch describes a tree that no longer exists.
Merging any other infra pull request moves `main`, and the bump pull requests
merge often, so a branch goes stale within minutes during a deploy session. The
verdict is `READY` or `BEHIND <n>`, never a bare number: a number printed in a
wall of output has been read as "fine".

**Generation.** `docker/res/*` files and the `env`/`image` values in
`docker/container.tf` reach a container only at creation, so the provider
replaces it. With `create_before_destroy` the new container is created while the
old one still holds the name, and the apply dies on
`Conflict. The container name "/fastcgi-69" is already in use` unless the same
pull request raises `local.fastcgi_generation`. The verdict is
`GENERATION BUMP OK (69 -> 70)`, `GENERATION NOT REQUIRED` or
`MISSING GENERATION BUMP`; see femiwiki/infra#783 and the failed apply of #806.

## Read the plan before the apply

An apply runs **before** the merge, so an applied-but-unmerged pull request
leaves `main` describing less than what is deployed, and an apply from any other
branch takes production back to it. The plan says so plainly when it is about to
happen:

```text
~ image = "…7045adc5" -> "…2f501144"  # forces replacement
~ name  = "fastcgi-60" -> "fastcgi-59"
Plan: 2 to add, 0 to change, 2 to destroy.
```

A bump should be `2 to add, 2 to destroy` with the generation going **up**.

## Watching the chain

```sh
.claude/skills/femiwiki-deploy-watch/fw-deploy watch-apply <pr>
.claude/skills/femiwiki-deploy-watch/fw-deploy watch-apply <pr> --run-id <id>
```

It waits, then prints the per-job conclusions and the run conclusion, exiting
non-zero unless the run succeeded. The selection rules it encodes:

- The apply is not a run of its own. It is the `<workspace> apply` job of the
  pull request's `pull_request` run, and that run shows `waiting` until the
  environment is approved. So the watcher follows the newest run for the head
  commit, and starting it before the approval is fine.
- An older run of the same pull request plans a commit the branch no longer
  has. A new run cancels such runs while they wait, and the apply job refuses
  a head that moved, so approving the wrong one fails before tofu starts.
- The run reads the workflow file from the pull request's branch, so a change
  under `.github/workflows/` or `.github/actions/` applies itself, including a
  new `TF_VAR_*`.

Guard the bump pull request's number before comparing it, or `[ "$num" -gt 0 ]`
errors on the literal string `null`:

```sh
num=$(gh pr list -R femiwiki/infra --head bump-femiwiki-image --state open \
  --json number -q '.[0].number')
case "$num" in ''|null) : still building ;; esac
```

**A change under `dockers/mediawiki/` takes a longer path**: it builds the
`mediawiki` image, which opens a bump pull request *inside docker-mediawiki*,
and only merging that builds `femiwiki`. Watching for the infra bump directly
will time out. Changes under `dockers/femiwiki/` go straight there.

## Probing the swap

Start the probe when the apply job is actually running, not when the deployment
is approved; a queued job can sit for many minutes and a fixed-length probe expires
before the swap.

```sh
until [ "$(gh api repos/femiwiki/infra/actions/runs/$id/jobs \
  --jq '.jobs[] | select(.name|test("apply")) | .status' | head -1)" = in_progress ]
do sleep 20; done
# then curl every 5s for ten minutes
```

Five-second samples show whether anything broke, not that nothing did: a window
under a second is easy to miss. Say "the probe saw no failure", not "zero
downtime". One refusal has been caught this way, at the moment the old container
is removed; see femiwiki/femiwiki#590.

## Verify afterwards

```sh
.claude/skills/femiwiki-deploy-watch/fw-deploy verify [probes]
```

It prints the declared generation from `origin/main:docker/locals.tf` and the
`fastcgi-A -> fastcgi-B` line from the newest successful apply run's log, and
says `ROLLBACK` when B is lower than A. A rollback has happened because a plan
saying `fastcgi-60 -> fastcgi-59` went unread.

The apply reporting success is not the deploy working. On the box, check the
thing that changed, not just that containers are up:

```sh
docker ps --format '{{.Names}} {{.Status}}' | grep -E '^(fastcgi|http)'
docker inspect fastcgi-<gen> --format '{{range .Config.Env}}{{println .}}{{end}}' | grep '^FW_'
curl -sS http://127.0.0.1:2019/config/   # the Caddy config actually loaded
```

The Caddyfile is passed in from `infra/docker/res/Caddyfile`, so grep **that**,
not the copy in docker-mediawiki, which is a bare fallback.

## Traps that have cost time

- A required status check and the workspace that reports it move in **one**
  change, in both directions. Registered without the workspace, nothing reports
  it and every pull request blocks. Left in the workspace's own pull request, it
  becomes required while that workspace's plan is still non-empty and every pull
  request blocks on a failure instead. Register it in a change that also touches
  the workspace's directory, so the check runs and has to be green for that
  change to merge. `enforce_admins = false` means an admin can merge past it,
  which rescues one pull request and not the next.
- Redirecting a watcher to `/dev/null` and then grepping the *other* task's
  output file for its result. Keep one watcher per background task.
- Reading infra files from the operator's working tree, which is on some branch.
  Use `git show origin/main:<path>` after a fetch.
- `pkill -f <script>` also matches the shell running the `pkill`.
- A Caddyfile or container-environment change forces replacement without moving
  the generation, and `create_before_destroy` then collides on the container
  name. Bump `fastcgi_generation` in the same pull request; see
  femiwiki/infra#783. `fw-deploy preflight` now refuses this.
