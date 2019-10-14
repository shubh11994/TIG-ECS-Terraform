variable "family" {
  default = "nginx"
}
variable "task_role_arn" {
  default = "arn:aws:iam::489284938287:role/ecsTaskExecutionRole"
}
variable "network_mode" {
  default = "awsvpc"
}
variable "launch_type" {
  default = "FARGATE"
}
variable "vpc_id" {}
variable "cluster_ID" {}
variable "IAM_profile_arn" {}
variable "aws_profile" {
  description = "AWS CLI profile name"
}
variable "aws_region" {}