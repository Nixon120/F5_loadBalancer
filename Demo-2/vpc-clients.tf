

################################################################################
# VPC for Clients
################################################################################


resource "aws_vpc" "clients" {
  cidr_block                = "10.1.0.0/16"
  enable_dns_hostnames      = true
  enable_dns_support        = true  
  tags = {
    Name = "Clients-VPC-${random_string.suffix.result}"
  }
}


################################################################################
# Subnets for Clients
################################################################################

resource "aws_subnet" "clients_subnet" {
  vpc_id     = aws_vpc.clients.id
  cidr_block = "10.1.1.0/24"
  availability_zone = "${var.region}a"
  tags = {
    Name = "Clients Subnet"
  }
}




################################################################################
# Internet Gateway
################################################################################

resource "aws_internet_gateway" "igw_clients" {
  vpc_id     = aws_vpc.clients.id

}


################################################################################
# Route Table Clients Subnets
################################################################################


resource "aws_route_table" "clients" {
  vpc_id     = aws_vpc.clients.id

  tags = {
    Name = "Clients route table"
  }
}


resource "aws_route" "public_internet_gateway_clients" {

  route_table_id         = aws_route_table.clients.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw_clients.id
}


################################################################################
# Associate Route Tables with Subnets
################################################################################


resource "aws_route_table_association" "clients" {
  subnet_id      = aws_subnet.clients_subnet.id
  route_table_id = aws_route_table.clients.id
}



resource "aws_vpc_peering_connection" "peering" {
  peer_vpc_id   = aws_vpc.main.id
  vpc_id        = aws_vpc.clients.id
  auto_accept   = true

  accepter {
    allow_remote_vpc_dns_resolution = true
  }

  requester {
    allow_remote_vpc_dns_resolution = true
  }

  tags = {
    Name = "VPC Peering between EKS and Clients"
  }
}


resource "aws_route" "route-2-eks" {
  route_table_id            = aws_route_table.clients.id
  destination_cidr_block    = "10.0.0.0/16"
  vpc_peering_connection_id = aws_vpc_peering_connection.peering.id
}

