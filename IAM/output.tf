output "aws_IAM_profile" {
  value = "${aws_iam_instance_profile.ecs_spot.arn}"
}