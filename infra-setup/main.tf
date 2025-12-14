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
    count = 2
    vpc_id = aws_vpc.mlops.id
    cidr_block = cidrsubnet(var.vpc_cidr,8,count.index+1)
    map_public_ip_on_launch = true
    tags = merge(
        var.tags,
        {
            Name = "${var.name}-Public-Subnet-${count.index}"
        }
    )
}

resource "aws_subnet" "private" {
    count = 2
    vpc_id = aws_vpc.mlops.id
    cidr_block = cidrsubnet(var.vpc_cidr,8,count.index + 101)
    map_public_ip_on_launch = false
    tags = merge(
        var.tags,
        {
            Name = "${var.name}-Private-Subnet-${count.index}"
        }
    )
}

resource "aws_route_table" "public" {
    vpc_id = aws_vpc.mlops.id
    route {
        cidr_block     = "0.0.0.0/0"
        nat_gateway_id = aws_internet_gateway.mlops.id
    }
    tags = merge(
        var.tags,
        {
            Name = "${var.name}-Public-RT"
        }
    )
}

resource "aws_route_table" "private" {
    vpc_id = aws_vpc.mlops.id
    route {
        cidr_block     = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.mlops[count.index].id
    }
    tags = merge(
        var.tags,
        {
            Name = "${var.name}-Private-RT"
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
    subnet_id      = aws_subnet.private[count.index].id
    route_table_id = aws_route_table.private.id
}

resource "aws_internet_gateway" "mlops" {
    vpc_id = aws_vpc.mlops.id
    tags = merge(
        var.tags,
        {
            Name = "${var.name}-igw-01"
        }
        
    )
}
resource "aws_internet_gateway_attachment" "mlops" {
  internet_gateway_id = aws_internet_gateway.mlops.id
  vpc_id              = aws_vpc.mlops.id
}

resource "aws_eip" "nat" {
  count  = 2
  domain = "vpc"

  tags = merge(
    var.tags,
    {
        
        Name = "${var.name}-nat-${count.index + 1}"
    })
}
resource "aws_nat_gateway" "mlops" {
  count = 2

  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = {
    Name = "${var.name}-nat-${count.index + 1}"
  }

  depends_on = [aws_internet_gateway.mlops]
}
