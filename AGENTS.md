# AGENTS.md

## Auto-merge

Open a pull request with auto-merge already on when every workspace it changes
has a required `<workspace> plan is empty` check:

```sh
gh pr merge <number> --squash --auto --delete-branch
```

Such a workspace is applied from GitHub Actions by a `tofu apply` comment,
before the merge, and its check passes only once the plan shows no changes,
which is after the apply. Auto-merge therefore waits for the apply, then merges
without anyone coming back to press the button. The required checks are
`required_status_checks_contexts` of `module "infra"` in `github/repo.tf`.

Do not turn auto-merge on for any other pull request:

- A workspace applied on merge by Terraform Cloud: its check is not required,
  so auto-merge would merge, and apply, before anyone reads the plan.
- A workspace whose plan check runs but is not required: auto-merge would not
  wait for the apply.
- A pull request that changes no workspace, such as `.github/`: nothing is
  applied, and the operator merges.
