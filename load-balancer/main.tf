module "maintenance_subnet" {
  source = "../subnet"
  vpcid = "${var.vpcid}"
  cidr = "${var.maintenance_cidr}"
  az = "${var.maintenance_az}"
  subnet_name = "${var.maintenance_name}"
}

module "maintenance_subnet_02" {
  source = "../subnet"
  vpcid = "${var.vpcid}"
  cidr = "${var.maintenance_cidr_2}"
  az = "${var.maintenance_az_2}"
  subnet_name = "${var.maintenance_name_2}"
}


resource "aws_lb" "devops_alb" {
  name               = "Spot-ALB"
  internal           = true
  load_balancer_type = "application"
  security_groups    = ["${var.devops_alb_sg}"]
  subnets            = ["${module.maintenance_subnet.subnet_id}", "${module.maintenance_subnet_02.subnet_id}"]

  #  enable_deletion_protection = true

  tags = {
    Environment = "staging"
  }
}
resource "aws_lb_listener" "grafana_lb_listner" {
  load_balancer_arn = "${aws_lb.devops_alb.arn}"
  port              = "80"
  protocol          = "HTTP"
  #  ssl_policy        = "ELBSecurityPolicy-2016-08"
  #  certificate_arn   = "arn:aws:iam::187416307283:server-certificate/test_cert_rab3wuqwgja25ct3n4jdj2tzu4"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.grafana_tg.arn}"
  }
}
resource "aws_lb_target_group" "grafana_tg" {
  name     = "ECS-grafana-tg"
  port     = 80
  target_type = "instance"
  protocol = "HTTP"
  vpc_id   = "${var.vpcid}"
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
output "grafana_tg_id" {
  value = "${aws_lb_target_group.grafana_tg.id}"
}

resource "aws_lb_listener_rule" "grafana" {
  listener_arn = "${aws_lb_listener.grafana_lb_listner.arn}"
  priority     = 90

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.grafana_tg.arn}"
  }

  condition {
    field  = "host-header"
    values = ["grafana.staging-we.com"]
  }
}
