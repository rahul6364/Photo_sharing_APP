module "alb" {
  source = "./modules/alb"

  vpc_id            = aws_vpc.main.id
  public_subnet_ids = [aws_subnet.public_1.id, aws_subnet.public_2.id]
  alb_name          = "photoshare-alb"
  target_group_name = "photoshare-tg"
}