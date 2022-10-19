module "app_tier_1" {
  source = "../../configs/app/modules/tier-1"

  project_root_path       = local.project_root_path
  helm_timeout_unit       = var.helm_timeout_unit
  helm_atomic             = var.helm_atomic
  sld                     = var.sld
  tld                     = var.tld
  persistent_volumes_root = var.persistent_volumes_root
  deployment_mode         = var.deployment_mode
}

module "ingress" {
  source            = "./modules/ingress"
  project_root_path = local.project_root_path
  helm_timeout_unit = var.helm_timeout_unit
  helm_atomic       = var.helm_atomic
  deployment_mode   = var.deployment_mode

  depends_on = [
    module.app_tier_1
  ]
}

module "app_tier_2" {
  source = "../../configs/app/modules/tier-2"

  project_root_rel_path = var.project_root_rel_path
  helm_timeout_unit     = var.helm_timeout_unit
  helm_atomic           = var.helm_atomic
  sld                   = var.sld
  tld                   = var.tld
  environment           = "local"
  cluster_name          = var.cluster_name
  ingress_sg            = "not-needed-in-local"
  deployment_mode       = var.deployment_mode

  depends_on = [
    module.ingress
  ]
}
