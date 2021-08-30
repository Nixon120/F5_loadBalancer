# BIG-IP Management Public IP Addresses
output mgmtPublicIP {
  description = "List of BIG-IP public IP addresses for the management interfaces"
  value       = aws_eip.mgmt.public_ip
}

# BIG-IP Management Public DNS
output mgmtPublicDNS {
  description = "List of BIG-IP public DNS records for the management interfaces"
  value       = aws_eip.mgmt.public_dns
}

output f5_username {
  value = var.f5_username
}

output bigip_password {
  value       = var.f5_password 
}


output private_addresses {
  description = "List of BIG-IP private addresses"
  value = aws_network_interface.ext.*.private_ips
}



output onboard_do {
  value      = data.template_file.clustermemberDO.rendered
  depends_on = [data.template_file.clustermemberDO]
}

output interface_id {
  value      = aws_network_interface.int.id
}


