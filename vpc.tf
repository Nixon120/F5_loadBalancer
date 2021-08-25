provider "aws" {
  region = var.region
}

data "aws_availability_zones" "available" {}

locals {
  cluster_name = "eks-${random_string.suffix.result}"
}

resource "random_string" "suffix" {
  length  = 4
  special = false
}



################################################################################
# VPC
################################################################################


resource "aws_vpc" "main" {
  cidr_block                = "10.0.0.0/16"
  enable_dns_hostnames      = true
  enable_dns_support        = true  
  tags = {
    Name = "EKS-VPC-${random_string.suffix.result}"
  }
}


################################################################################
# Subnets for EKS
################################################################################

resource "aws_subnet" "private-eks1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "${var.region}a"
  tags = {
    Name = "EKS-private-1"
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = "1"
  }
}


resource "aws_subnet" "private-eks2" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "${var.region}b"
  tags = {
    Name = "EKS-private-2"
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = "1"
  }
}


resource "aws_subnet" "public-eks1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "${var.region}a"
  tags = {
    Name = "EKS-public-1"
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = "1"
  }
}

################################################################################
# Subnets for F5
################################################################################

resource "aws_subnet" "int" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.5.0/24"
  availability_zone = "${var.region}a"
  tags = {
    Name = "F5 Internal Subnet"
  }
}

resource "aws_subnet" "ext" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.6.0/24"
  availability_zone = "${var.region}a"
  tags = {
    Name = "F5 External Subnet"
  }
}
resource "aws_subnet" "mgmt" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.7.0/24"
  availability_zone = "${var.region}a"
  tags = {
    Name = "F5 Mgmt Subnet"
  }
}



################################################################################
# Internet Gateway
################################################################################

resource "aws_internet_gateway" "igw" {
  vpc_id     = aws_vpc.main.id

}


################################################################################
# Route Table Public Subnets
################################################################################


resource "aws_route_table" "public" {
  vpc_id     = aws_vpc.main.id

  tags = {
    Name = "Public route table"
  }
}


resource "aws_route" "public_internet_gateway" {

  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}



################################################################################
# Route Table EKS
################################################################################


resource "aws_route_table" "eks" {
  vpc_id     = aws_vpc.main.id
    route {
      cidr_block = "0.0.0.0/0"
      nat_gateway_id = aws_nat_gateway.gw.id
    }
  tags = {
    Name = "EKS route table"
  }
}

resource "aws_eip" "nat" {
  vpc      = true
}

resource "aws_nat_gateway" "gw" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public-eks1.id

  tags = {
    Name = "gw NAT"
  }
}



################################################################################
# Route Table F5 Internal
################################################################################


resource "aws_route_table" "f5_int" {
  vpc_id     = aws_vpc.main.id
  tags = {
    Name = "F5 Internal route table"
  }
}


################################################################################
# Associate Route Tables with Subnets
################################################################################


resource "aws_route_table_association" "mgmt" {
  subnet_id      = aws_subnet.mgmt.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "ext" {
  subnet_id      = aws_subnet.ext.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "int" {
  subnet_id      = aws_subnet.int.id
  route_table_id = aws_route_table.f5_int.id
}

resource "aws_route_table_association" "private-eks1" {
  subnet_id      = aws_subnet.private-eks1.id
  route_table_id = aws_route_table.eks.id
}

resource "aws_route_table_association" "private-eks2" {
  subnet_id      = aws_subnet.private-eks2.id
  route_table_id = aws_route_table.eks.id
}

resource "aws_route_table_association" "public-eks1" {
  subnet_id      = aws_subnet.public-eks1.id
  route_table_id = aws_route_table.public.id
}



################################################################################
# Create Random IDs
################################################################################

resource "random_id" "id" {
  byte_length = 2
}

resource "random_id" "bucket_id" {
  byte_length = 5
}
resource random_string password {
  length      = 16
  min_upper   = 1
  min_lower   = 1
  min_numeric = 1
  special     = false
}



################################################################################
# Create Secret Store and Store BIG-IP Password (NOT USED)
#######   We use the password instead #######
################################################################################


resource "aws_secretsmanager_secret" "bigip" {
  name = format("%s-bigip-secret-%s", var.prefix, random_id.id.hex)
}
resource "aws_secretsmanager_secret_version" "bigip-pwd" {
  secret_id     = aws_secretsmanager_secret.bigip.id
  secret_string = random_string.password.result
}

resource "tls_private_key" "example" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = format("%s-%s-%s", var.prefix, var.ec2_key_name, random_id.id.hex)
  public_key = tls_private_key.example.public_key_openssh
}


################################################################################
# Create AS3  bucket for CFE
################################################################################



resource "aws_s3_bucket" "example" {
  bucket =  "my-bucket-cfe-${random_id.bucket_id.dec}"
  force_destroy = true
  
  tags = {
    f5_cloud_failover_label = "cfe-deployment"
  }
}

################################################################################
# Create 2 BIG-IPs in HA Pair
################################################################################


module bigip02 {
  source                      = "./modules/bigip"
  aws_iam_instance_profile    = aws_iam_instance_profile.f5_cloud_failover_profile.name
  prefix                      = "02"
  mgmt_subnet_ids             = aws_subnet.mgmt.id
  mgmt_private_ip             = ["10.0.7.101"]
  mgmt_securitygroup_ids      = [aws_security_group.mgmt.id]
  ext_subnet_ids             = aws_subnet.ext.id
  ext_private_ip             = ["10.0.6.11"]
  ext_securitygroup_ids      = [aws_security_group.ext.id]
  int_subnet_ids             = aws_subnet.int.id
  int_private_ip             = ["10.0.5.11"]
  int_securitygroup_ids      = [aws_security_group.int.id]
  ha_remote_f5               = "10.0.7.100"
  ha_primary_f5              = "10.0.7.100"  
  IP_count                   = 10
  INIT_URL                   = var.INIT_URL
  DO_URL                     = var.DO_URL
  AS3_URL                    = var.AS3_URL
  TS_URL                     = var.TS_URL
  CFE_URL                    = var.CFE_URL
  FAST_URL                   = var.FAST_URL
  f5_username                = var.f5_username
  f5_password                = var.f5_password
  ec2_key_name               = aws_key_pair.generated_key.key_name
  ec2_instance_type          = var.ec2_instance_type
  f5_ami_search_name         = var.f5_ami_search_name

}


module bigip01 {
  source                      = "./modules/bigip"
  aws_iam_instance_profile    = aws_iam_instance_profile.f5_cloud_failover_profile.name
  prefix                      = "01"
  mgmt_subnet_ids             = aws_subnet.mgmt.id
  mgmt_private_ip             = ["10.0.7.100"]
  mgmt_securitygroup_ids      = [aws_security_group.mgmt.id]
  ext_subnet_ids             = aws_subnet.ext.id
  ext_private_ip             = ["10.0.6.10"]
  ext_securitygroup_ids      = [aws_security_group.ext.id]
  int_subnet_ids             = aws_subnet.int.id
  int_private_ip             = ["10.0.5.10"]
  int_securitygroup_ids      = [aws_security_group.int.id]
  ha_remote_f5               = "10.0.7.101"
  ha_primary_f5              = "10.0.7.100"
  IP_count                   = 0
  INIT_URL                   = var.INIT_URL
  DO_URL                     = var.DO_URL
  AS3_URL                    = var.AS3_URL
  TS_URL                     = var.TS_URL
  CFE_URL                    = var.CFE_URL
  FAST_URL                   = var.FAST_URL
  f5_username                = var.f5_username
  f5_password                = var.f5_password
  ec2_key_name               = aws_key_pair.generated_key.key_name
  ec2_instance_type          = var.ec2_instance_type
  f5_ami_search_name         = var.f5_ami_search_name

}


