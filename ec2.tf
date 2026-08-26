module "ec2" {
  source = "./modules/ec2"

  vpc_id = aws_vpc.main.id

  subnet_id = var.public_subnet_names[0]

  alb_security_group_id = module.alb.alb_security_group_id

  target_group_arn = module.alb.target_group_arn

  iam_instance_profile = aws_iam_instance_profile.ec2.name

  s3_bucket_name = module.s3.bucket_id

  secret_name = module.secrets.secret_name

  # Set this to the key pair you created in the lab.
  key_name = var.key_name

  instance_type = "t3.micro"
  instance_name = "photoshare-web"
}