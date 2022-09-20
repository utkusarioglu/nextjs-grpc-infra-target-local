provider "helm" {
  kubernetes {
    config_path    = "~/.kube/config"
    config_context = "docker-desktop"
  }
  experiments {
    manifest = true
  }
}

provider "local" { }
