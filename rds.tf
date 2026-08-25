module "rds" {
  source             = "./modules/rds"
  vpc_id             = aws_vpc.main.id
  vpc_cidr           = var.vpc_cidr
  private_subnet_ids = [aws_subnet.private_1.id, aws_subnet.private_2.id]
  db_password        = var.db_password
  db_name            = var.db_name
  db_username        = var.db_username
  db_identifier      = var.db_identifier

}