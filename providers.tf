provider "helm" {
  kubernetes {
    config_path    = "~/.kube/config"
    config_context = "k3d-${var.cluster_name}"
  }
  experiments {
    manifest = true
  }
}

provider "local" {}

provider "null" {}

provider "time" {}
