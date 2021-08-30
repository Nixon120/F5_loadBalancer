################################################################################
# Create Management Network Interface
################################################################################

resource "aws_network_interface" "mgmt" {
  subnet_id       = var.mgmt_subnet_ids
  security_groups = var.mgmt_securitygroup_ids
  private_ips     = var.mgmt_private_ip

  tags = {
    Name   = format("%s-%d", "BIGIP-mgmt", var.prefix)
  }
}

################################################################################
# add an elastic IP to the BIG-IP management interface
################################################################################

resource "aws_eip" "mgmt" {
  network_interface = aws_network_interface.mgmt.id
  vpc               = true
}

################################################################################
# Create External Network Interface
################################################################################

resource "aws_network_interface" "ext" {
  subnet_id             = var.ext_subnet_ids
  security_groups       = var.ext_securitygroup_ids
  private_ips           = var.ext_private_ip
  private_ips_count     = var.IP_count
  source_dest_check     = false

  tags = {
    Name   = format("%s-%d", "BIGIP-ext", var.prefix)
    f5_cloud_failover_label = "cfe-deployment"
    f5_cloud_failover_nic_map = "external"
  }
}

################################################################################
# add an elastic IP to the BIG-IP ext interface
################################################################################

resource "aws_eip" "ext" {
  network_interface = aws_network_interface.ext.id
  vpc               = true
}

################################################################################
# Create Management Network Interfaces
################################################################################

resource "aws_network_interface" "int" {
  subnet_id             = var.int_subnet_ids
  security_groups       = var.int_securitygroup_ids
  private_ips           = var.int_private_ip
  source_dest_check     = false
  tags = {
    Name   = format("%s-%d", "BIGIP-int", var.prefix)
    f5_cloud_failover_label = "cfe-deployment"
    f5_cloud_failover_nic_map = "internal"  
  }
}


################################################################################
# Find BIG-IP AMI
################################################################################

#
data "aws_ami" "f5_ami" {
  most_recent = true
  owners = ["aws-marketplace"]

  filter {
    name   = "description"
    values = [var.f5_ami_search_name]
  }
}


################################################################################
# Create runtime-init file
################################################################################

data "template_file" "user_data_vm0" {
  template = file("${path.module}/f5_onboard.tmpl")
  vars = {
    bigip_username         = var.f5_username
    ssh_keypair            = fileexists("~/.ssh/id_rsa.pub") ? file("~/.ssh/id_rsa.pub") : var.ec2_key_name
    aws_secretmanager_auth = false
    bigip_password         = var.f5_password
    INIT_URL               = var.INIT_URL,
    DO_URL                 = var.DO_URL,
    DO_VER                 = split("/", var.DO_URL)[7]
    AS3_URL                = var.AS3_URL,
    AS3_VER                = split("/", var.AS3_URL)[7]
    TS_VER                 = split("/", var.TS_URL)[7]
    TS_URL                 = var.TS_URL,
    CFE_URL                = var.CFE_URL,
    CFE_VER                = split("/", var.CFE_URL)[7]
    FAST_URL               = var.FAST_URL,
    FAST_VER               = split("/", var.FAST_URL)[7]
    hostname               = aws_eip.mgmt.public_dns
    self-ip-ext            = var.ext_private_ip[0]
    gateway_servers        = cidrhost(format("%s/24", var.int_private_ip[0]), 1)
    gateway                = cidrhost(format("%s/24", var.ext_private_ip[0]), 1)
    self-ip-int            = var.int_private_ip[0]
    ha_remote_f5           = var.ha_remote_f5
    ha_primary_f5          = var.ha_primary_f5

  }
}



resource aws_instance f5_bigip {
  instance_type         = var.ec2_instance_type
  ami                   = data.aws_ami.f5_ami.id
  key_name              = var.ec2_key_name

  root_block_device {
    delete_on_termination = true
  }

  # set the mgmt interface
  network_interface {
      network_interface_id = aws_network_interface.mgmt.id
      device_index         = 0
    }

  # set the private interface
  network_interface {
      network_interface_id = aws_network_interface.ext.id
      device_index         = 1
  }

  network_interface {
      network_interface_id = aws_network_interface.int.id
      device_index         = 2
  }
  iam_instance_profile = var.aws_iam_instance_profile
  user_data            = data.template_file.user_data_vm0.rendered
  provisioner "local-exec" {
    command = "sleep 420"
  }
  tags = {
    Name   = format("%s-%d", "BIGIP-", var.prefix)
  }
  depends_on = [aws_eip.mgmt, aws_network_interface.mgmt, aws_network_interface.ext, aws_network_interface.int]
}



data template_file clustermemberDO {
  template = file("${path.module}/onboard_do_3nic.tpl")
  vars = {
    hostname      = aws_eip.mgmt.public_dns
    self-ip1      = var.ext_private_ip[0]
    gateway       = cidrhost(format("%s/24", var.int_private_ip[0]), 1)
    self-ip2      = var.int_private_ip[0]
  }
  depends_on = [aws_eip.mgmt, aws_network_interface.mgmt, aws_network_interface.ext, aws_network_interface.int]
}