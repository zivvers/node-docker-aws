resource "aws_s3_bucket" "charliemcgrady_temp_photos" {
  bucket = "${var.temp_photos_bucket_name}"
  acl = "private"
}
