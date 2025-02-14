data "aws_lb" "nodegroupLb" {
  name = "ALB-cliente"
}

data "aws_iam_role" "LabRole" {
  name = "LabRole"
}