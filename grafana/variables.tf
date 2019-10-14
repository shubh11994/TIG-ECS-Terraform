variable "family" {
  default = "grafana"
}
variable "task_role_arn" {
  default = "arn:aws:iam::489284938287:role/ecsTaskExecutionRole"
}
variable "network_mode" {
  default = "bridge"
}

/*------------------------------Service -------------------------------------------------------------*/
variable "scheduling_strategy" {
  default = "REPLICA"
}
variable "launch_type" {
  default = "EC2"
}
variable "desired_count" {
  default = "1"
}
variable "deployment_maximum_percent" {
  default = "200"
}
variable "deployment_minimum_healthy_percent" {
  default = "100"
}
variable "health_check_grace_period_seconds" {
  default = "120"
}
variable "container_port" {
  default = "3000"
}
/*------------------------------Auto Scaling--------------------------------------------------------*/
variable "max_capacity" {
  default = "1"
}
variable "min_capacity" {
  default = "1"
}
variable "resource_id" {
  default = "service/staging-spot/grafana"
}
variable "role_arn" {
  default = "arn:aws:iam::489284938287:role/aws-service-role/ecs.application-autoscaling.amazonaws.com/AWSServiceRoleForApplicationAutoScaling_ECSService"
}
variable "scalable_dimension" {
  default = "ecs:service:DesiredCount"
}
variable "service_namespace" {
  default = "ecs"
}
variable "target_value" {
  default = "75"
}
variable "scale_in_cooldown" {
  default = "300"
}
variable "scale_out_cooldown" {
  default = "300"
}
variable "vpc_id" {}
variable "cluster_ID" {}
variable "IAM_profile_arn" {}
variable "aws_profile" {
  description = "AWS CLI profile name"
}
variable "aws_region" {}
variable "grafana_tg_arn" {}