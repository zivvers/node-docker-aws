# ecr_repository_url is outputed so release scripts know where to release new images 
output "ecr_repository_url" {
  value = "${module.node_server_ecs_service.ecr_repository_url}"
}

# ecs_cluster_name is outputed so release scripts know which cluster to update
output "ecs_cluster_name" {
  value = "${var.ecs_cluster_name}"
}
