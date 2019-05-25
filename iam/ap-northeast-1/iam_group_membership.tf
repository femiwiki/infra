resource "aws_iam_group_membership" "Admin" {
  group = "Admin"
  name  = "Admin"
  users = ["gmlthak12", "damdam", "Nagyeop", "simnalamburt"]
}
