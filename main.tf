module "vpc_peering" {
  source         = "./module/vpc_peering"
  main_region    = var.main_region
  peer_regions   = var.peer_regions
  main_vpc_cidr  = var.main_vpc_cidr
  peer_vpc_cidrs = var.peer_vpc_cidrs
  peer_auto_accept = var.peer_auto_accept
}
