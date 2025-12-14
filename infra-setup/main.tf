resource "aws_s3_bucket" "mlops" {
  bucket = var.bucket_name
  tags = var.tags
}

resource "aws_s3_bucket_versioning" "mlops"{
    bucket = aws_s3_bucket.mlops.id
    versioning_configuration {
        status = "Enabled"
  }
}

resource "aws_vpc" "mlops" {
  cidr_block = var.vpc_cidr
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = merge(
    var.tags,
    {
        Name = "${var.name}-vpc-01"
    }
  )
}

resource "aws_subnet" "public" {
    count = length(data.aws_availability_zones.available)
    vpc_id = aws_vpc.mlops.id
    cidr_block = cidrsubnet(var.vpc_cidr,8,count.index)
    map_public_ip_on_launch = true
    tags = merge(
        var.tags,
        {
            name = "${var.name}-Public-Subnet-${count.index}"
        }
    )
}

resource "aws_subnet" "private" {
    count = length(data.aws_availability_zones.available)
    vpc_id = aws_vpc.mlops.id
    cidr_block = cidrsubnet(var.vpc_cidr,8,count.index + 100)
    map_public_ip_on_launch = false
    tags = merge(
        var.tags,
        {
            name = "${var.name}-Private-Subnet-${count.index}"
        }
    )
}

resource "aws_route_table" "public" {
    vpc_id = aws_vpc.mlops.id
    tags = merge(
        var.tags,
        {
            name = "${var.name}-Public-RT"
        }
    )
}

resource "aws_route_table" "private" {
    vpc_id = aws_vpc.mlops.id
    tags = merge(
        var.tags,
        {
            name = "${var.name}-Public-RT"
        }
    )
}

resource "aws_route_table_association" "public" {
    count = length(aws_subnet.public)
    subnet_id      = aws_subnet.public[count.index].id
    route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
    count = length(aws_subnet.private)
    subnet_id      = aws_subnet.public[count.index].id
    route_table_id = aws_route_table.private.id
}
