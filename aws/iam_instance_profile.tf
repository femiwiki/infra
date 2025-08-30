resource "aws_iam_instance_profile" "femiwiki" {
  name = "Femiwiki"
  role = aws_iam_role.femiwiki.name
}

resource "aws_iam_instance_profile" "database" {
  name = "database"
  role = aws_iam_role.database.name
}
