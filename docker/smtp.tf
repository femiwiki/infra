# A new SES SMTP key every generation, on a user per parity so a failed N fixed
# at N+2 never needs a third key (femiwiki/femiwiki#528)

# SES derives the SMTP password from the secret for the region that receives the
# mail, which is LocalSettings.php's host
provider "aws" {
  alias  = "ses"
  region = "us-east-1"
}

resource "aws_iam_access_key" "smtp" {
  provider = aws.ses
  user     = "femiwiki-email-${local.fastcgi_generation % 2}"

  # fastcgi, which uploads it, would force this anyway
  lifecycle {
    create_before_destroy = true
  }
}
