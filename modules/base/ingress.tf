resource "helm_release" "ingress" {
  count             = 1
  name              = "ingress"
  chart             = "${var.project_root_path}/ingress"
  dependency_update = true
  namespace         = "api"
  timeout           = var.helm_timeout_unit
  atomic            = var.helm_atomic
  depends_on = [
    helm_release.certificates[0],
    # helm_release.jaeger[0]
  ]

  # set {
  #   name  = "cloudProvider.isLocal"
  #   value = var.environment == "local"
  # }

  # set {
  #   name  = "cloudProvider.isAws"
  #   value = var.environment == "aws"
  # }

}
