##############################
# Output Resources
##############################

output "ecs_cluster_name" {
  description = "ECS cluster name"
  value       = aws_ecs_cluster.college_cluster.name
}

output "ecs_service_name" {
  description = "ECS service name"
  value       = aws_ecs_service.college_service.name
}

output "ecs_task_definition" {
  description = "ECS task definition ARN"
  value       = aws_ecs_task_definition.college_task.arn
}
