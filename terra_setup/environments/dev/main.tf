
locals {
  env = "dev"
}

provider "google" {
  project = "${var.project}"
}


module "credentials" {
  source  = "../../modules/credentials"
  project = "${var.project}"
  env     = "${local.env}"
}

module "big_query" {
  source  = "../../modules/big_query"
  project = "${var.project}"
  env     = "${local.env}"
}


