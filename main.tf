module "base" {
  source            = "./modules/base"
  project_root_path = local.project_root_path
  helm_timeout_unit = var.helm_timeout_unit
  helm_atomic       = var.helm_atomic
}

module "ingress" {
  source            = "./modules/ingress"
  project_root_path = local.project_root_path
  helm_timeout_unit = var.helm_timeout_unit
  helm_atomic       = var.helm_atomic

  depends_on = [
    module.base
  ]
}

module "app" {
  source = "../../configs/app"

  project_root_rel_path = var.project_root_rel_path
  helm_timeout_unit     = var.helm_timeout_unit
  helm_atomic           = var.helm_atomic
  sld                   = var.sld
  tld                   = var.tld
  environment           = "local"
  cluster_name          = var.cluster_name
  ingress_sg            = "not-needed-in-local"

  depends_on = [
    module.ingress
  ]
}
