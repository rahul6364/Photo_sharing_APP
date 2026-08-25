variable "vpc_id" {
  type = string
}
variable "alb_name" {
  type    = string
  default = "photoshare-alb"
}
variable "public_subnet_ids" {
  type = list(string)
}
variable "target_group_name" {
  type    = string
  default = "photoshare-tg"
}