module "base" {
  source            = "./modules/base"
  project_root_path = local.project_root_path
  helm_timeout_unit = var.helm_timeout_unit
  helm_atomic       = var.helm_atomic
}

module "app" {
  source = "../app"

  project_root_rel_path = var.project_root_rel_path
  helm_timeout_unit     = var.helm_timeout_unit
  helm_atomic           = var.helm_atomic
  sld                   = var.sld
  tld                   = var.tld
  environment           = "local"
  cluster_name          = var.cluster_name

  depends_on = [
    module.base
  ]
}
