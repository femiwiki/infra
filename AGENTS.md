# AGENTS.md

## Auto-merge

Open a pull request that changes `docker/` or `grafana/` with auto-merge
already on:

```sh
gh pr merge <number> --squash --auto --delete-branch
```

These workspaces are applied from GitHub Actions by a `tofu apply` comment,
before the merge. `docker plan is empty` and `grafana plan is empty` are
required checks, and each passes only once the plan shows no changes, which is
after the apply. Auto-merge therefore waits for the apply, then merges without
anyone coming back to press the button.

Do not turn auto-merge on for any other pull request:

- `aws/` and `github/`: Terraform Cloud applies these on merge, and its check
  is not required, so auto-merge would merge, and apply, before anyone reads
  the plan.
- `healthchecks/`: `healthchecks plan is empty` runs but is not required, so
  auto-merge would not wait for the apply.
- Everything else, such as `.github/`: nothing is applied, and the operator
  merges.
