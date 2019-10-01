output "task_arn" {
  value = "${aws_ecs_task_definition.task.arn}"
}

output "service_id" {
  value = "${aws_ecs_service.service.id}"
}

output "iam_role_id" {
  value = "${aws_iam_role.ecs_service_role.id}"
}

output "ecr_repository_url" {
  value = "${aws_ecr_repository.ecr_repository.repository_url}"
}
