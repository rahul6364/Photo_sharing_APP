resource "aws_security_group" "this" {
  name        = "photoshare-web-sg"
  description = "Security group for Web Server"
  vpc_id      = var.vpc_id

  ingress  {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [var.alb_security_group_id]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

data "aws_ami" "amazon_linux" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
resource "aws_instance" "this" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type

  subnet_id                   = var.subnet_id
  associate_public_ip_address = true

  vpc_security_group_ids = [
    aws_security_group.this.id
  ]

  iam_instance_profile = var.iam_instance_profile

  key_name = var.key_name

  user_data = templatefile("${path.module}/user_data.sh.tftpl", {
    s3_bucket_name = var.s3_bucket_name
    secret_name    = var.secret_name
  })

  user_data_replace_on_change = true

  tags = {
    Name = var.instance_name
  }
}
resource "aws_lb_target_group_attachment" "this" {
  target_group_arn = var.target_group_arn
  target_id        = aws_instance.this.id
  port             = 80
}