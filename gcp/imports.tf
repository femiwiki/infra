# Made by hand in the bootstrap of #1160
import {
  for_each = local.github_actions_services

  to = google_project_service.github_actions[each.key]
  id = "${local.project}/${each.key}"
}

import {
  to = google_iam_workload_identity_pool.github
  id = "projects/${local.project}/locations/global/workloadIdentityPools/github"
}

import {
  to = google_iam_workload_identity_pool_provider.infra
  id = "projects/${local.project}/locations/global/workloadIdentityPools/github/providers/femiwiki-infra"
}

import {
  for_each = local.github_actions

  to = google_service_account.github_actions[each.key]
  id = "projects/${local.project}/serviceAccounts/${each.key}@${local.project}.iam.gserviceaccount.com"
}

import {
  for_each = local.github_actions_roles

  to = google_project_iam_member.github_actions[each.key]
  id = "${local.project} ${each.value.role} serviceAccount:${each.value.account}@${local.project}.iam.gserviceaccount.com"
}

import {
  for_each = local.github_actions

  to = google_service_account_iam_member.github_actions[each.key]
  id = "projects/${local.project}/serviceAccounts/${each.key}@${local.project}.iam.gserviceaccount.com roles/iam.workloadIdentityUser principal://iam.googleapis.com/projects/611763704636/locations/global/workloadIdentityPools/github/subject/${each.value.subject}"
}
