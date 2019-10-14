output "grafana_tg" {
  value = "${aws_lb_target_group.grafana_tg.arn}"
}