resource "aws_db_subnet_group" "this" {
  name        = "photoshare-db-group"
  description = "DB Subnet Group for PhotoShare"

  subnet_ids = var.private_subnet_ids
}
resource "aws_security_group" "this" {
  name        = "db-sg"
  description = "Security group for PhotoShare RDS database"
  vpc_id      = var.vpc_id

  ingress {
    description = "MySQL access from VPC"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}
resource "aws_db_instance" "this" {
  identifier     = var.db_identifier
  engine         = "mysql"
  engine_version = "8.4"
  instance_class = "db.t3.micro"

  allocated_storage = 20
  storage_type      = "gp3"

  username = var.db_username
  password = var.db_password
  db_name  = var.db_name

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.this.id]
  publicly_accessible    = false
  multi_az               = false

  backup_retention_period = 0
  skip_final_snapshot     = true

}