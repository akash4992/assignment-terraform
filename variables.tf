variable "main_region" {
  description = "Main region for VPC peering"
  type        = string
}

variable "peer_regions" {
  description = "List of regions to peer with the main region"
  type        = list(string)
}

variable "main_vpc_cidr" {
  description = "CIDR block for the main VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "peer_vpc_cidrs" {
  description = "CIDR blocks for peer VPCs"
  type        = list(string)
  default     = ["10.1.0.0/16", "10.2.0.0/16"]
}

variable "peer_auto_accept" {
  description = "Automatically accept peering requests"
  type        = bool
  default     = false
}
