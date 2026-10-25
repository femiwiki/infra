# Read-only access to the metrics for femiwiki.github.io's availability collector,
# handed over through github/secrets.tf
resource "grafana_cloud_access_policy" "github_io" {
  provider = grafana.cloud
  region   = data.grafana_cloud_stack.femiwiki.region_slug
  name     = "femiwiki-github-io"
  scopes   = ["metrics:read"]

  realm {
    type       = "stack"
    identifier = data.grafana_cloud_stack.femiwiki.id
  }
}

resource "grafana_cloud_access_policy_token" "github_io" {
  provider         = grafana.cloud
  region           = data.grafana_cloud_stack.femiwiki.region_slug
  access_policy_id = grafana_cloud_access_policy.github_io.policy_id
  name             = "femiwiki-github-io"
}

# Lets MediaWiki send Excimer's slow-request profiles (femiwiki/femiwiki#614),
# handed over through github/secrets.tf and aws/ssm.tf
resource "grafana_cloud_access_policy" "mediawiki_profiles" {
  provider = grafana.cloud
  region   = data.grafana_cloud_stack.femiwiki.region_slug
  name     = "mediawiki-profiles"
  scopes   = ["profiles:write"]

  realm {
    type       = "stack"
    identifier = data.grafana_cloud_stack.femiwiki.id
  }
}

resource "grafana_cloud_access_policy_token" "mediawiki_profiles" {
  provider         = grafana.cloud
  region           = data.grafana_cloud_stack.femiwiki.region_slug
  access_policy_id = grafana_cloud_access_policy.mediawiki_profiles.policy_id
  name             = "mediawiki-profiles"
}
