# Much of this configuration was inspired by https://www.ybrikman.com/writing/2016/03/31/infrastructure-as-code-microservices-aws-docker-terraform-ecs/ and https://www.ybrikman.com/writing/2016/03/31/infrastructure-as-code-microservices-aws-docker-terraform-ecs/
# If you are new to Terraform or AWS, I would recommend reading those articles first.

provider "aws" {
  profile = "${var.aws_profile}"
  region  = "${var.aws_region}"
}

module "vpc" {
  source             = "./modules/vpc"
  name               = "charliemcgrady"
  ip_address_for_ssh = "${var.ip_address_for_ssh}"
}

module "rds" {
  source     = "./modules/rds"
  name       = "charliemcgrady-production-db"
  subnet_ids = module.vpc.private_subnet_ids
  password   = "${var.db_password}"
  vpc_id     = module.vpc.vpc_id
}

module "node_server_alb" {
  source = "./modules/alb"

  name = "node-server-alb"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.public_subnet_ids

  instance_port     = "${var.node_server_port}"
  health_check_path = "/ping"
}

module "ecs_cluster" {
  source = "./modules/ecs-cluster"

  name = "charliemcgrady-production-cluster"

  # Only supply one t2.micro to the cluster so we stay within the AWS free tier
  # As traffic increases, these two values can be increased. 

  # If you do increase these values, make sure to tweak deployment_maximum_percent,
  # desired_count, and deployment_minimum_healthy_percent in the node_server_ecs_service. 
  #
  # An example of more scaled configuration would be:
  #   size = 6
  #   desired_count = 3
  #   deployment_maximum_percent = 200
  #   deployment_minimum_healthy_percent = 100
  #
  # With these values, a deployment to the node_server_ecs_service would:
  #    - Start capacity at 3 server
  #    - Bring up 3 additional servers (to achieve 200% capacity)
  #    - Bring down 3 servers when applying the new image
  #    - Bring up these 3 servers with the new image.
  #    - Bring down the 3 servers running the old image
  size          = 1
  instance_type = "t2.micro"

  key_pair_name = "${var.key_pair_name}"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.public_subnet_ids

  security_group_ids = ["${module.vpc.ssh_security_group_id}"]

  allow_inbound_ports_and_cidr_blocks = {
    "${var.node_server_port}" : module.vpc.public_cidr_blocks
  }
}

module "node_server_ecs_service" {
  source = "./modules/ecs-service"

  name           = "node-server"
  ecs_cluster_id = "${module.ecs_cluster.ecs_cluster_id}"

  image         = "${var.node_server_image}"
  image_version = "${var.node_server_image_version}"

  # These values match the t2.micro specs so we stay in the free tier.
  # If these values don't fit into instance_type in the ecs_cluster,
  # ECS will be unable to deploy the containers to the target hosts.
  cpu    = 1000
  memory = 768

  desired_count = 1

  container_port      = "${var.node_server_port}"
  host_port           = "${var.node_server_port}"
  lb_target_group_arn = "${module.node_server_alb.lb_target_group_arn}"
  elb_name            = "${module.node_server_alb.elb_name}"

  num_env_vars = 2
  env_vars = "${map(
    "DB_HOST", "${module.rds.rds_host_name}",
    "DB_PASSWORD", "${var.db_password}"
  )}"
}
