resource "aws_lb_target_group" "spot_tg" {
  name     = "spot-tg"
  port     = 80
  target_type = "ip"
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"
  deregistration_delay = "60"
  health_check = {
    port                = "traffic-port"
    protocol            = "HTTP"
    interval            = "10"
    path                = "/login"
    timeout             = "2"
    healthy_threshold   = "2"
    unhealthy_threshold = "2"
    matcher             = "200"
  }
  tags = {
    Terraform = "true"
    Environment = "staging"
  }
}

resource "aws_lb_listener_rule" "sample" {
  listener_arn = "arn:aws:elasticloadbalancing:ap-south-1:489284938287:listener/app/Staging-ECS-ALB/ac6241e2bd3e7d88/754ee7ab935f5dbf"
  priority     = 85

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.spot_tg.arn}"
  }

  condition {
    field  = "host-header"
    values = ["spot.staging-we.com"]
  }
}

resource "aws_ecs_task_definition" "task_defn" {
  family                              = "${var.family}"
  container_definitions               = "${file("fargate-service/container_def.json")}"
  task_role_arn                       = "${var.task_role_arn}"
  execution_role_arn                  = "${var.task_role_arn}"
  network_mode                        = "${var.network_mode}"
  requires_compatibilities            = ["${var.launch_type}"]
  cpu = "1024"
  memory = "2048"
}

resource "aws_ecs_service" "sample" {
  name            = "nginx"
  cluster         = "${var.cluster_ID}"
  task_definition = "${aws_ecs_task_definition.task_defn.arn}"
  desired_count   = 1
  #iam_role        = "arn:aws:iam::489284938287:role/ecsServiceRole"
  launch_type     = "FARGATE"
  network_configuration {
    subnets = ["subnet-03055638aa52f42a4", "subnet-01ea51c1e6ddf3d4f"]
  }
  load_balancer {
    target_group_arn = "${aws_lb_target_group.spot_tg.arn}"
    container_name   = "nginx"
    container_port   = 80
  }
}