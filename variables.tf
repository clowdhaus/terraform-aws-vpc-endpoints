variable "vpc_id" {
  description = "The ID of the VPC in which the endpoint will be used"
  type        = string
}

variable "tags" {
  description = "A map of tags to use on all resources"
  type        = map(string)
  default     = {}
}

variable "timeouts" {
  description = "Define maximum timeout for creating, updating, and deleting VPC endpoint resources"
  type        = map(string)
  default     = {}
}

# Gateway endpoint
variable "gateway_endpoints" {
  description = "A map of gateway endpoints containing their properties and configurations"
  type        = any
  default     = {}
}

# Interface endpoints
variable "interface_endpoints" {
  description = "A map of interface endpoints containing their properties and configurations"
  type        = any
  default     = {}
}

variable "auto_accept" {
  description = "Automatically default to accept the VPC endpoint connections"
  type        = string
  default     = null
}

variable "security_group_ids" {
  description = "Default security group IDs to associate with the VPC endpoints"
  type        = list(string)
  default     = []
}

variable "subnet_ids" {
  description = "Default subnets IDs to associate with the VPC endpoints"
  type        = list(string)
  default     = []
}
