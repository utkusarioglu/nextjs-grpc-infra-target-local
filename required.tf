terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "2.6.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "3.1.1"
    }
    time = {
      source  = "hashicorp/time"
      version = "0.8.0"
    }
  }
}
