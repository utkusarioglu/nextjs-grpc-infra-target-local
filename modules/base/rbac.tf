resource "helm_release" "rbac" {
  count             = 1
  name              = "rbac"
  chart             = "${var.project_root_path}/rbac"
  dependency_update = true
  atomic            = true

  depends_on = [
    helm_release.namespaces[0]
  ]
}
