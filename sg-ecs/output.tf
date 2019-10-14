output "ECS_SG" {
  value = "${aws_security_group.ecs_cluster.id}"
}
output "grafana_SG" {
  value = "${aws_security_group.grafana.id}"
}
output "devops_SG" {
  value = "${aws_security_group.devops_alb_sg.id}"
}