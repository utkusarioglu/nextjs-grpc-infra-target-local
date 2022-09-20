resource "helm_release" "networking" {
  count             = 1
  name              = "networking"
  chart             = "${var.project_root_path}/networking"
  dependency_update = true
  atomic            = true

  depends_on = [
    helm_release.namespaces[0]
  ]
}
