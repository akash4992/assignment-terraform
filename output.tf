output "main_vpc_id" {
  value = module.vpc_peering.main_vpc_id
}

output "peer_vpc_1_id" {
  value = module.vpc_peering.peer_vpc_1_id
}

output "peer_vpc_2_id" {
  value = module.vpc_peering.peer_vpc_2_id
}

output "main_to_peer_1_peering_connection_id" {
  value = module.vpc_peering.main_to_peer_1_peering_connection_id
}

output "main_to_peer_2_peering_connection_id" {
  value = module.vpc_peering.main_to_peer_2_peering_connection_id
}
