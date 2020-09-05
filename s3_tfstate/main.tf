module "tfstate_bucket" {
  source = "./modules/s3"

  env          = "sandbox"
  service_name = "terraform"
}
