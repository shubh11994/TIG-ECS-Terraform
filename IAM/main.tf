resource "aws_iam_role" "ecs_host_role_spot" {
  name = "ecs_host_role_spot"
  assume_role_policy = "${file("./IAM/policies/ecs-role.json")}"
}

resource "aws_iam_role_policy" "ecs_instance_role_policy_spot" {
  name = "ecs_instance_role_policy_spot"
  policy = "${file("./IAM/policies/ecs-instance-role-policy.json")}"
  role = "${aws_iam_role.ecs_host_role_spot.id}"
}

resource "aws_iam_role" "ecs_service_role_spot" {
  name = "ecs_service_role_spot"
  assume_role_policy = "${file("./IAM/policies/ecs-role.json")}"
}

resource "aws_iam_role_policy" "ecs_service_role_policy_spot" {
  name = "ecs_service_role_policy_spot"
  policy = "${file("./IAM/policies/ecs-service-role-policy.json")}"
  role = "${aws_iam_role.ecs_service_role_spot.id}"
}

resource "aws_iam_instance_profile" "ecs_spot" {
  name = "ecs-instance-profile_spot"
  path = "/"
  role = "${aws_iam_role.ecs_host_role_spot.name}"
}