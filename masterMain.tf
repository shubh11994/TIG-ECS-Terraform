module "IAM" {
  source = "./IAM"
  aws_profile = "${var.aws_profile}"
  version = "~> v1.50.0"
  aws_region = "${var.aws_region}"
}

module "ECS-Cluster" {
  source = "./ECS-Cluster"
  version = "~> v1.50.0"
  aws_profile = "${var.aws_profile}"
  instance_type = "${var.instance_type}"
  spot_price = "${var.spot_price}"
  key_name = "non_prod"
  ecs_cluster_name = "staging-spot"
  max_spot_instances = "${var.max_count}"
  min_spot_instances = "${var.min_count}"
  ami_id = "${var.ami_ID}"
  subnet_ids = "${var.subnet_id}"
  sg_id = "${module.sg-ecs.ECS_SG}"
  IAM_profile_arn = "${module.IAM.aws_IAM_profile}"
  aws_region = "${var.aws_region}"
}

module "sg-ecs" {
  source = "./sg-ecs"
  aws_profile = "${var.aws_profile}"
  ecs_cluster_name = "staging-spot"
  vpc_id = "${var.vpc_id}"
  version = "~> v1.50.0"
  aws_region = "${var.aws_region}"
}

module "grafana" {
  source = "grafana"
  IAM_profile_arn = "${module.IAM.aws_IAM_profile}"
  cluster_ID = "${module.ECS-Cluster.cluster-ID}"
  vpc_id = "${var.vpc_id}"
  aws_profile = "${var.aws_profile}"
  aws_region = "${var.aws_region}"
  grafana_tg_arn = "${module.load-balancer.grafana_tg}"
}
module "load-balancer" {
  source = "load-balancer"
  maintenance_az = "ap-south-1a"
  maintenance_cidr = "10.0.11.0/28"
  maintenance_name = "spot-1"
  vpcid = "${var.vpc_id}"
  aws_profile = "${var.aws_profile}"
  aws_region = "${var.aws_region}"
  devops_alb_sg = "${module.sg-ecs.devops_SG}"
  maintenance_cidr_2 = "10.0.12.0/28"
  maintenance_name_2 = "spot-2"
  maintenance_az_2 = "ap-south-1b"
}