# AGENTS.md

## Auto-merge

Open a pull request with auto-merge already on when every workspace it changes
is planned by `.github/workflows/tofu.yaml`:

```sh
gh pr merge <number> --squash --auto
```

Such a workspace is applied before the merge: when its plan has changes, the
`<workspace> apply` job of the pull request's run waits for the environment of
the same name, and approving that deployment is the apply. The required
`tofu gate` check reports only after that job, so auto-merge waits for the
approval and the apply, then merges without anyone coming back to press the
button. The required checks are `required_status_checks_contexts` of
`module "infra"` in `github/repo.tf`.

Do not turn auto-merge on for any other pull request:

- A workspace applied on merge by Terraform Cloud: nothing asks before it
  applies, so auto-merge would merge, and apply, before anyone reads the plan.
- A pull request that changes no workspace, such as `.github/`: nothing is
  applied, and the operator merges.
