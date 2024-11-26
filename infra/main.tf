resource "null_resource" "install_layer_dependencies" {
  provisioner "local-exec" {
    command = "cd ../lambda_function/identify-client/app && npm install"
  }

  triggers = {
    requirements_hash = filesha256("../lambda_function/identify-client/app/package.json")
    app_hash          = filesha256("../lambda_function/identify-client/app/app.mjs")
  }
}

data "archive_file" "lambda" {
  type        = "zip"
  source_dir  = "../lambda_function/identify-client/app"
  output_path = "lambda_function.zip"
  depends_on = [
    null_resource.install_layer_dependencies
  ]
}

resource "aws_lambda_function" "lambda_base" {
  filename         = "lambda_function.zip"
  function_name    = var.functionName
  role             = data.aws_iam_role.LabRole.arn
  handler          = "app.lambdaHandler"
  memory_size      = 128
  timeout          = 100
  source_code_hash = data.archive_file.lambda.output_base64sha256
  runtime          = var.runtime

  depends_on = [
    data.archive_file.lambda
  ]

  environment {
    variables = {
      ALB_EKS = data.aws_lb.nodegroupLb.dns_name
    }
  }
}
