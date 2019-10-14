resource "aws_ecs_cluster" "main" {
  name = "${var.ecs_cluster_name}"
}
output "main_id" {
  value = "${aws_ecs_cluster.main.id}"
}

resource "aws_launch_configuration" "ecs_config_launch_config_spot" {
  name_prefix   = "${var.ecs_cluster_name}_ecs_cluster_spot"
  image_id      = "${var.ami_id}"
  instance_type = "${var.instance_type}"
  spot_price    = "${var.spot_price}"
  enable_monitoring = true
  lifecycle {
    create_before_destroy = true
  }
  user_data = <<EOF
#!/bin/bash
echo ECS_CLUSTER=${var.ecs_cluster_name} >> /etc/ecs/ecs.config
echo ECS_INSTANCE_ATTRIBUTES={\"purchase-option\":\"spot\"} >> /etc/ecs/ecs.config
/usr/bin/enable-ec2-spot-hibernation
EOF
  security_groups = ["${var.sg_id}"]
  key_name = "${var.key_name}"
  iam_instance_profile = "${var.IAM_profile_arn}"
}

resource "aws_autoscaling_group" "ecs_cluster_spot" {
  name_prefix               = "${aws_launch_configuration.ecs_config_launch_config_spot.name}_ecs_cluster_spot"
  termination_policies = ["OldestInstance"]
  max_size                  = "${var.max_spot_instances}"
  min_size                  = "${var.min_spot_instances}"
  launch_configuration      = "${aws_launch_configuration.ecs_config_launch_config_spot.name}"
  lifecycle {
    create_before_destroy = true
  }
  vpc_zone_identifier       = ["${var.subnet_ids}"]
}
/*
resource "aws_sqs_queue" "terraform_queue" {
  name                        = "terraform-example-queue.fifo"
  fifo_queue                  = true
  content_based_deduplication = true
}

resource "aws_autoscaling_lifecycle_hook" "foobar" {
  name                   = "LCH-spot"
  autoscaling_group_name = "${aws_autoscaling_group.ecs_cluster_spot.name}"
  default_result         = "CONTINUE"
  heartbeat_timeout      = 2000
  lifecycle_transition   = "autoscaling:EC2_INSTANCE_LAUNCHING"

  notification_metadata = <<EOF
{
  "foo": "bar"
}
EOF

  notification_target_arn = "${aws_sqs_queue.terraform_queue.arn}"
  role_arn                = "${var.IAM_profile_arn}"
}
/*
resource "aws_autoscaling_policy" "ecs_cluster_scale_policy" {
  name                   = "${var.ecs_cluster_name}_ecs_cluster_spot_scale_policy"
  policy_type            = "TargetTrackingScaling"
  adjustment_type        = "ChangeInCapacity"
  autoscaling_group_name = "${aws_autoscaling_group.ecs_cluster_spot.name}"

  target_tracking_configuration {
    customized_metric_specification {
      metric_dimension {
        name = "ClusterName"
        value = "${var.ecs_cluster_name}"
      }
      metric_name = "MemoryReservation"
      namespace = "AWS/ECS"
      statistic = "Average"
    }
    target_value = 70.0
  }
}
*/
resource "aws_autoscaling_policy" "CPUReservationScaleUpPolicy" {
  name                   = "ecs_spot_staging_policy"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = "${aws_autoscaling_group.ecs_cluster_spot.name}"
}

resource "aws_cloudwatch_metric_alarm" "CPUReservationHighAlert" {
  alarm_name          = "staging-spot-CPU-Reservation"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUReservation"
  namespace           = "AWS/ECS"
  period              = "120"
  statistic           = "Maximum"
  threshold           = "80"

  dimensions = {
    ClusterName = "${aws_ecs_cluster.main.name}"
  }

  alarm_description = "This metric monitors ecs cpu reservation"
  alarm_actions     = ["${aws_autoscaling_policy.CPUReservationScaleUpPolicy.arn}"]
}