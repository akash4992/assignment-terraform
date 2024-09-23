
provider "aws" {
  alias  = "main_region"
  region = var.main_region
}

provider "aws" {
  alias  = "peer_region_1"
  region = var.peer_regions[0]
}

provider "aws" {
  alias  = "peer_region_2"
  region = var.peer_regions[1]
}


# Create main VPC in the main region
resource "aws_vpc" "main_vpc" {
  provider   = aws.main_region
  cidr_block = var.main_vpc_cidr
  tags = {
    Name = "Main-VPC"
  }
}


# Create security group for the main VPC
resource "aws_security_group" "main_vpc_sg" {
  provider    = aws.main_region
  vpc_id      = aws_vpc.main_vpc.id
  name        = "Main-VPC-SG"
  description = "Security group for main VPC"

  # Ingress rule allowing all traffic from main VPC CIDR block
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # Allowing all protocols
    cidr_blocks = [aws_vpc.main_vpc.cidr_block]
  }

  # Egress rule allowing all traffic to any IP
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # Allowing all protocols
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Main-VPC-SG"
  }
}

# Create a subnet in the main VPC
resource "aws_subnet" "main_vpc_subnet" {
  provider                = aws.main_region
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = var.main_vpc_subnet_cidr
  map_public_ip_on_launch = true  # Automatically assign public IP to instances in this subnet

  tags = {
    Name = "Main-VPC-Subnet"
  }
}

# Create an internet gateway for the main VPC
resource "aws_internet_gateway" "main_vpc_igw" {
  provider = aws.main_region
  vpc_id   = aws_vpc.main_vpc.id

  tags = {
    Name = "Main-VPC-IGW"
  }
}

# Add a route to the internet through the internet gateway for the main VPC
resource "aws_route" "main_vpc_internet_route" {
  provider                  = aws.main_region
  route_table_id            = aws_vpc.main_vpc.main_route_table_id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id                = aws_internet_gateway.main_vpc_igw.id

  depends_on = [
    aws_internet_gateway.main_vpc_igw
  ]
}



# Create peer VPC in the first peer region
resource "aws_vpc" "peer_vpc_1" {
  provider   = aws.peer_region_1
  cidr_block = var.peer_vpc_cidrs[0]
  tags = {
    Name = "Peer-VPC-1"
  }
}

# Security group for peer VPC 1
resource "aws_security_group" "peer_vpc_1_sg" {
  provider    = aws.peer_region_1
  vpc_id      = aws_vpc.peer_vpc_1.id
  name        = "Peer-VPC-1-SG"
  description = "Security group for peer VPC 1"

  # Ingress rule allowing all traffic from peer VPC 1
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # Allowing all protocols
    cidr_blocks = [aws_vpc.peer_vpc_1.cidr_block]
  }

  # Egress rule allowing all traffic to any IP
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # Allowing all protocols
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Peer-VPC-1-SG"
  }
}


# Create peer VPC in the second peer region
resource "aws_vpc" "peer_vpc_2" {
  provider   = aws.peer_region_2
  cidr_block = var.peer_vpc_cidrs[1]
  tags = {
    Name = "Peer-VPC-2"
  }
}

# Security group for peer VPC 2
resource "aws_security_group" "peer_vpc_2_sg" {
  provider    = aws.peer_region_2
  vpc_id      = aws_vpc.peer_vpc_2.id
  name        = "Peer-VPC-2-SG"
  description = "Security group for peer VPC 2"
  ingress {
    description = "Allow traffic from main VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # For all protocols
    cidr_blocks = [aws_vpc.main_vpc.cidr_block]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # For all protocols
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Peer VPC 2 SG"
  }
}

# Create VPC peering between main VPC and peer VPC 1
resource "aws_vpc_peering_connection" "main_to_peer_1" {
  provider    = aws.main_region
  vpc_id      = aws_vpc.main_vpc.id
  peer_vpc_id = aws_vpc.peer_vpc_1.id
  peer_region = var.peer_regions[0]
  auto_accept = var.peer_auto_accept
  tags = {
    Name = "Main-to-Peer-1"
  }

  depends_on = [
    aws_vpc.main_vpc,
    aws_vpc.peer_vpc_1
  ]
}

# Create VPC peering between main VPC and peer VPC 2
resource "aws_vpc_peering_connection" "main_to_peer_2" {
  provider    = aws.main_region
  vpc_id      = aws_vpc.main_vpc.id
  peer_vpc_id = aws_vpc.peer_vpc_2.id
  peer_region = var.peer_regions[1]
  auto_accept = var.peer_auto_accept
  tags = {
    Name = "Main-to-Peer-2"
  }

  depends_on = [
    aws_vpc.main_vpc,
    aws_vpc.peer_vpc_2
  ]
}

# Add route for main VPC to peer VPC 1
resource "aws_route" "main_to_peer_1_route" {
  provider                  = aws.main_region
  route_table_id            = aws_vpc.main_vpc.main_route_table_id
  destination_cidr_block    = aws_vpc.peer_vpc_1.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.main_to_peer_1.id

  depends_on = [
    aws_vpc_peering_connection.main_to_peer_1
  ]
}

# Add route for peer VPC 1 to main VPC
resource "aws_route" "peer_1_to_main_route" {
  provider                  = aws.peer_region_1
  route_table_id            = aws_vpc.peer_vpc_1.main_route_table_id
  destination_cidr_block    = aws_vpc.main_vpc.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.main_to_peer_1.id

  depends_on = [
    aws_vpc_peering_connection.main_to_peer_1
  ]
}

# Add route for main VPC to peer VPC 2
resource "aws_route" "main_to_peer_2_route" {
  provider                  = aws.main_region
  route_table_id            = aws_vpc.main_vpc.main_route_table_id
  destination_cidr_block    = aws_vpc.peer_vpc_2.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.main_to_peer_2.id

  depends_on = [
    aws_vpc_peering_connection.main_to_peer_2
  ]
}

# Add route for peer VPC 2 to main VPC
resource "aws_route" "peer_2_to_main_route" {
  provider                  = aws.peer_region_2
  route_table_id            = aws_vpc.peer_vpc_2.main_route_table_id
  destination_cidr_block    = aws_vpc.main_vpc.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.main_to_peer_2.id

  depends_on = [
    aws_vpc_peering_connection.main_to_peer_2
  ]
}


# Accept VPC peering connection in peer region 1
resource "aws_vpc_peering_connection_accepter" "peer_1_accepter" {
  provider                 = aws.peer_region_1
  vpc_peering_connection_id = aws_vpc_peering_connection.main_to_peer_1.id
  auto_accept              = true

  tags = {
    Name = "Peer-1-to-Main-Accepter"
  }

  depends_on = [
    aws_vpc_peering_connection.main_to_peer_1
  ]
}

# Accept VPC peering connection in peer region 2
resource "aws_vpc_peering_connection_accepter" "peer_2_accepter" {
  provider                 = aws.peer_region_2
  vpc_peering_connection_id = aws_vpc_peering_connection.main_to_peer_2.id
  auto_accept              = true

  tags = {
    Name = "Peer-2-to-Main-Accepter"
  }

  depends_on = [
    aws_vpc_peering_connection.main_to_peer_2
  ]
}
