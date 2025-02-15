data "aws_availability_zones" "available" {}

module vpc {
    source = "terraform-aws-modules/vpc/aws"
   
    name = "clickhouse-vpc"
    cidr = "10.0.0.0/16"
    
    azs = data.aws_availability_zones.available.names
    private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
    public_subnets =  ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
    
    enable_nat_gateway = true
    single_nat_gateway = true
    
    enable_dns_hostnames= true
    tags = {
        "Name" = "clickhouse-vpc"
    }
    public_subnet_tags = {
        "Name" = "clickhouse-public-subnet"
    }
    private_subnet_tags = {
        "Name" = "clickhouse-private-subnet"
    }
}

resource "aws_security_group_rule" "ssh" {
  security_group_id = "${ module.vpc.default_security_group_id }"
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "SSH allow"

  depends_on = [
    module.vpc
  ] 
}

resource "aws_security_group_rule" "outbound" {
  security_group_id = "${ module.vpc.default_security_group_id }"
  type              = "egress"
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  description       = "All outbound traffic allow"

  depends_on = [
    module.vpc
  ] 
}