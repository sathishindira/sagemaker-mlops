data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_caller_identity" "current" {}

# data "aws_ami" "amazon_linux" {
#   most_recent = true

#   filter {
#     name   = "name"
#     values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
#   }

# }