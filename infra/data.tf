data "aws_lb" "nodegroupLb" {
  name = "ALB-${var.projectName}"
}

data "aws_iam_role" "LabRole" {
  name = "LabRole"
}