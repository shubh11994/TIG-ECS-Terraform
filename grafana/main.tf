resource "aws_ecs_task_definition" "task_defn" {
  family                              = "${var.family}"
  container_definitions               = "${file("./grafana/container_def.json")}"
  task_role_arn                       = "${var.task_role_arn}"
  execution_role_arn                  = "${var.task_role_arn}"
  network_mode                        = "${var.network_mode}"
  requires_compatibilities            = ["${var.launch_type}"]
}
/*------------------------------Service-------------------------------------------------------------*/
resource "aws_ecs_service" "service" {
  name                                = "${var.family}"
  task_definition                     = "${aws_ecs_task_definition.task_defn.arn}"
  launch_type                         = "${var.launch_type}"
  desired_count                       = "${var.desired_count}"
  scheduling_strategy                 = "${var.scheduling_strategy}"
  cluster                             = "${var.cluster_ID}"
  iam_role                            = "arn:aws:iam::489284938287:role/ecsServiceRole"
  deployment_maximum_percent          = "${var.deployment_maximum_percent}"
  deployment_minimum_healthy_percent  = "${var.deployment_minimum_healthy_percent}"
  health_check_grace_period_seconds   = "${var.health_check_grace_period_seconds}"
  load_balancer {
    target_group_arn                  = "${var.grafana_tg_arn}"
    container_name                    = "${var.family}"
    container_port                    = "${var.container_port}"
  }
}
/*------------------------------Auto Scaling--------------------------------------------------------*/
resource "aws_appautoscaling_target" "target" {
  max_capacity                        = "${var.max_capacity}"
  min_capacity                        = "${var.min_capacity}"
  resource_id                         = "${var.resource_id}"
  role_arn                            = "${var.role_arn}"
  scalable_dimension                  = "${var.scalable_dimension}"
  service_namespace                   = "${var.service_namespace}"
  depends_on                          = ["aws_ecs_service.service"]
}
resource "aws_appautoscaling_policy" "policy" {
  name                                = "${var.family}-cpu-as-policy"
  service_namespace                   = "${aws_appautoscaling_target.target.service_namespace}"
  scalable_dimension                  = "${aws_appautoscaling_target.target.scalable_dimension}"
  resource_id                         = "${aws_appautoscaling_target.target.resource_id}"
  policy_type                         = "TargetTrackingScaling"
  depends_on = ["aws_appautoscaling_target.target"]

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type          = "ECSServiceAverageMemoryUtilization"
    }

    target_value                      = "${var.target_value}"
    scale_in_cooldown                 = "${var.scale_in_cooldown}"
    scale_out_cooldown                = "${var.scale_out_cooldown}"
  }
}