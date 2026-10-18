resource "aws_iam_instance_profile" "femiwiki" {
  name = "Femiwiki"
  role = module.femiwiki.name
}

resource "aws_iam_instance_profile" "database" {
  name = "database"
  role = module.database.name
}
