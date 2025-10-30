##############################
# Variables for ECS Deployment
##############################

variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "us-east-1"
}

variable "image_url" {
  description = "Full ECR image URL with tag"
  type        = string
  example     = "312596057535.dkr.ecr.us-east-1.amazonaws.com/college-website"
}

variable "subnet_ids" {
  description = "List of subnet IDs in your VPC"
  type        = list(string)
}

variable "security_group_id" {
  description = "Security group ID to attach to ECS service"
  type        = string
}
