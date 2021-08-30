variable prefix {
  type        = string
}

variable mgmt_subnet_ids {
  type        = string
}
variable mgmt_securitygroup_ids {
  type        = list
}

variable mgmt_private_ip {
  type        = list
}

variable ext_subnet_ids {
  type        = string
}
variable ext_securitygroup_ids {
  type        = list
}

variable ext_private_ip {
  type        = list
}

variable int_subnet_ids {
  type        = string
}
variable int_securitygroup_ids {
  type        = list
}

variable int_private_ip {
  type        = list
}

variable "IP_count" {
}

variable "ha_remote_f5" {}
variable "ha_primary_f5" {}

variable "ec2_key_name" {
  type        = string
}

variable f5_username {
   type        = string
}
variable f5_password {
     type        = string

}
variable f5_ami_search_name {
     type        = string

}
variable ec2_instance_type {}

variable aws_secretmanager_auth {
  type        = bool
  default     = false
}

variable aws_secretmanager_secret_id {
  type        = string
  default     = null
}

variable aws_iam_instance_profile {
  description = "aws_iam_instance_profile"
  type        = string
  default     = null
}

variable DO_URL {}
variable AS3_URL {}
variable TS_URL {}
variable CFE_URL {}
variable FAST_URL {}
variable INIT_URL {}
