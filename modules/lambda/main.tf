data "archive_file" "this" {
  type        = "zip"
  source_file = var.source_file
  output_path = "${path.module}/lambda_function.zip"
}
resource "aws_lambda_function" "this" {
  function_name    = var.function_name
  filename         = data.archive_file.this.output_path
  source_code_hash = data.archive_file.this.output_base64sha256
  runtime          = "python3.13"
  handler          = "lambda_handler.lambda_handler"
  architectures    = ["x86_64"]

  role = var.role_arn

  environment {
    variables = {
      S3_BUCKET = var.s3_bucket_name
      ALB_DNS   = var.alb_dns_name
    }
  }

}
resource "aws_lambda_permission" "s3" {
  statement_id = "AllowS3Invoke"
  action       = "lambda:InvokeFunction"

  function_name = aws_lambda_function.this.function_name
  principal     = "s3.amazonaws.com"

  source_arn = var.s3_bucket_arn
}
resource "aws_s3_bucket_notification" "this" {
  bucket = var.s3_bucket_name

  lambda_function {
    lambda_function_arn = aws_lambda_function.this.arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [
    aws_lambda_permission.s3
  ]
}