module "aws-prod" {
  source = "../../infra"
  instance_size = "t2.micro"
  instance_ami = "ami-0eb199b995e2bc4e3"
  region_aws = "us-west-2"
  ssh_key = "iac-prod"
  security_group = "PROD"
  group_name = "Prod"
  group_max_size = 10
  group_min_size = 1
  is_prod = true
}

# output "IP" {
#     value = module.aws-prod.PUBLIC_IP
# }
