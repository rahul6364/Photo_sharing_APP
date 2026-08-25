module "lambda" {
  source         = "./modules/lambda"
  role_arn       = aws_iam_role.lambda.arn
  s3_bucket_name = module.s3.bucket_id
  alb_dns_name   = module.alb.alb_dns_name

  function_name = "photoshare-metadata-extractor"
  source_file   = "${path.root}/lambda_handler.py"
  s3_bucket_arn = module.s3.bucket_arn
}