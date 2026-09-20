locals {
  programmatic_users = [
    "femiwiki-email",
    "terraform-cloud",
  ]
}

resource "aws_iam_account_password_policy" "strict" {
  allow_users_to_change_password = true
  minimum_password_length        = 14
}

resource "aws_iam_openid_connect_provider" "github_actions" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["1b511abead59c6ce207077c0bf0e0043b1382612"]
}

#
# IAM Users
#
resource "aws_iam_user" "programmatic_users" {
  for_each = toset(local.programmatic_users)
  name     = each.key
}

resource "aws_iam_user_policy" "ses_sending_access" {
  name   = "AmazonSesSendingAccess"
  user   = "femiwiki-email"
  policy = data.aws_iam_policy_document.ses_sending_access.json
}

resource "aws_iam_user_policy" "terraform_cloud" {
  depends_on = [aws_iam_user.programmatic_users["terraform-cloud"]]
  name       = "TerraformCloud"
  user       = "terraform-cloud"
  policy     = data.aws_iam_policy_document.iac.json
}


#
# IAM Groups
#
resource "aws_iam_group" "admin" {
  name = "Admin"
}

resource "aws_iam_group_policy_attachment" "admin_permission" {
  group      = aws_iam_group.admin.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess" # AWS managed policy
}

resource "aws_iam_group_policy_attachment" "admin_mfa" {
  group      = aws_iam_group.admin.name
  policy_arn = aws_iam_policy.force_mfa.arn
}

resource "aws_iam_group" "readonly" {
  name = "ReadOnly"
}

resource "aws_iam_group_policy_attachment" "readonly_permission" {
  group      = aws_iam_group.readonly.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess" # AWS managed policy
}

resource "aws_iam_group_policy_attachment" "readonly_mfa" {
  group      = aws_iam_group.readonly.name
  policy_arn = aws_iam_policy.force_mfa.arn
}


#
# IAM Roles
#
resource "aws_iam_role" "github_lambda" {
  name               = "github-lambda"
  description        = "Allows GitHub Actions workflows of femiwiki/lambda to deploy the DiscordNoti function."
  assume_role_policy = data.aws_iam_policy_document.github_lambda_assume_role.json
}

data "aws_iam_policy_document" "github_lambda_assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github_actions.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:femiwiki/lambda:ref:refs/heads/main"]
    }
  }
}

resource "aws_iam_role_policy" "github_lambda" {
  name   = "GithubLambda"
  role   = aws_iam_role.github_lambda.name
  policy = data.aws_iam_policy_document.github_lambda.json
}

resource "aws_iam_role" "femiwiki_github_io" {
  name               = "femiwiki-github-io"
  description        = "Allows GitHub Actions workflows of femiwiki/femiwiki.github.io to read billing figures."
  assume_role_policy = data.aws_iam_policy_document.femiwiki_github_io_assume_role.json
}

data "aws_iam_policy_document" "femiwiki_github_io_assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github_actions.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:femiwiki@21275875/femiwiki.github.io@1377892969:ref:refs/heads/main"]
    }
  }
}

resource "aws_iam_role_policy" "femiwiki_github_io" {
  name   = "FemiwikiGithubIo"
  role   = aws_iam_role.femiwiki_github_io.name
  policy = data.aws_iam_policy_document.femiwiki_github_io.json
}

resource "aws_iam_role" "infra_docker" {
  name               = "infra-docker"
  description        = "Allows GitHub Actions workflows of femiwiki/infra to plan and apply the docker workspace."
  assume_role_policy = data.aws_iam_policy_document.infra_docker_assume_role.json
}

data "aws_iam_policy_document" "infra_docker_assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github_actions.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values = [
        "repo:femiwiki@21275875/infra@188597503:ref:refs/heads/main",
        "repo:femiwiki@21275875/infra@188597503:pull_request",
      ]
    }
  }
}

resource "aws_iam_role_policy" "infra_docker" {
  name   = "InfraDocker"
  role   = aws_iam_role.infra_docker.name
  policy = data.aws_iam_policy_document.infra_docker.json
}

resource "aws_iam_role" "discord_noti" {
  name               = "DiscordNoti"
  description        = "Execution role for the DiscordNoti Lambda function."
  assume_role_policy = data.aws_iam_policy_document.discord_noti_assume_role.json
}

data "aws_iam_policy_document" "discord_noti_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy" "discord_noti" {
  name   = "DiscordNoti"
  role   = aws_iam_role.discord_noti.name
  policy = data.aws_iam_policy_document.discord_noti.json
}

resource "aws_iam_role" "femiwiki" {
  name               = "Femiwiki"
  description        = "Allows EC2 instances to call AWS services on your behalf."
  assume_role_policy = data.aws_iam_policy_document.instance_assume_role.json
}

data "aws_iam_policy_document" "instance_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "femiwiki_amazon_s3_access" {
  role       = aws_iam_role.femiwiki.name
  policy_arn = aws_iam_policy.amazon_s3_access.arn
}

resource "aws_iam_role_policy_attachment" "femiwiki_route53" {
  role       = aws_iam_role.femiwiki.name
  policy_arn = aws_iam_policy.route53.arn
}

resource "aws_iam_role_policy_attachment" "femiwiki_download_secrets" {
  role       = aws_iam_role.femiwiki.name
  policy_arn = aws_iam_policy.download_secrets.arn
}

resource "aws_iam_role_policy_attachment" "femiwiki_access_caddycerts" {
  role       = aws_iam_role.femiwiki.name
  policy_arn = aws_iam_policy.access_caddycerts.arn
}

resource "aws_iam_role_policy_attachment" "femiwiki_read_secret_parameters" {
  role       = aws_iam_role.femiwiki.name
  policy_arn = aws_iam_policy.read_secret_parameters.arn
}

resource "aws_iam_role_policy_attachment" "femiwiki_upload_backup" {
  role       = aws_iam_role.femiwiki.name
  policy_arn = aws_iam_policy.upload_backup.arn
}

resource "aws_iam_role_policy_attachment" "femiwiki_managed_policies" {
  for_each = toset([
    "AmazonSSMManagedInstanceCore",
    "CloudWatchAgentServerPolicy",
  ])
  role       = aws_iam_role.femiwiki.name
  policy_arn = "arn:aws:iam::aws:policy/${each.key}"
}

resource "aws_iam_role" "database" {
  name               = "database"
  description        = "EC2 instance(s) running database"
  assume_role_policy = data.aws_iam_policy_document.instance_assume_role.json
}

resource "aws_iam_role_policy_attachment" "database_upload_backup" {
  role       = aws_iam_role.database.name
  policy_arn = aws_iam_policy.upload_backup.arn
}

resource "aws_iam_role_policy_attachment" "database_managed_policies" {
  for_each = toset([
    "AmazonSSMManagedInstanceCore",
    "CloudWatchAgentServerPolicy",
  ])
  role       = aws_iam_role.database.name
  policy_arn = "arn:aws:iam::aws:policy/${each.key}"
}

resource "aws_iam_role" "infra_grafana" {
  name               = "infra-grafana"
  description        = "Allows GitHub Actions workflows of femiwiki/infra to keep the grafana workspace's state in S3."
  assume_role_policy = data.aws_iam_policy_document.infra_grafana_assume_role.json
}

data "aws_iam_policy_document" "infra_grafana_assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github_actions.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values = [
        "repo:femiwiki/infra:pull_request",
        "repo:femiwiki/infra:environment:grafana",
      ]
    }
  }
}

resource "aws_iam_role_policy" "infra_grafana" {
  name   = "InfraGrafana"
  role   = aws_iam_role.infra_grafana.name
  policy = data.aws_iam_policy_document.infra_grafana.json
}
