resource "helm_release" "ingress" {
  count             = 1
  name              = "ingress"
  chart             = "${var.project_root_path}/ingress"
  dependency_update = true
  namespace         = "api"
  timeout           = var.helm_timeout_unit
  atomic            = var.helm_atomic
}
