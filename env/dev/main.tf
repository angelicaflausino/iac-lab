module "aws_dev" {
  source = "../../infra"
  instance_ami = "ami-0eb199b995e2bc4e3"
  instance_size = "t2.micro"
  region_aws = "us-west-2"
  ssh_key = "iac-dev"
  security_group = "DEV"
  group_name = "Dev"
  group_max_size = 1
  group_min_size = 0
  is_prod = false
}

# output "IP" {
#     value = module.aws_dev.PUBLIC_IP
# }