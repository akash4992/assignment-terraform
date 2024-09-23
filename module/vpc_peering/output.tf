output "main_vpc_id" {
  value = aws_vpc.main_vpc.id
}

output "peer_vpc_1_id" {
  value = aws_vpc.peer_vpc_1.id
}

output "peer_vpc_2_id" {
  value = aws_vpc.peer_vpc_2.id
}

output "main_to_peer_1_peering_connection_id" {
  value = aws_vpc_peering_connection.main_to_peer_1.id
}

output "main_to_peer_2_peering_connection_id" {
  value = aws_vpc_peering_connection.main_to_peer_2.id
}
