resource "random_id" "s3_suffix" {
  byte_length = 4
}

module "s3" {
  source      = "./modules/s3"
  bucket_name = "photoshare-assets-${random_id.s3_suffix.hex}"
}