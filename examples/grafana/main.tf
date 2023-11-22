terraform {
  required_version = ">= 1.0"

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.23.0"
    }
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

resource "kubernetes_namespace_v1" "example" {
  metadata {
    name = "grafana-svc"
  }
}

module "this" {
  source = "../.."

  infrastructure = {
    namespace = kubernetes_namespace_v1.example.metadata[0].name
  }

  deployment = {
    timeout = 30
  }

  containers = [
    {
      image = "grafana/grafana:latest"
      execute = {
        as_user = 472 # start as grafana user
      }
      resources = {
        cpu    = 1
        memory = 1024 # Mi
      }
      ports = [
        {
          internal = 3000
          external = 3000
        }
      ]
      checks = [
        {
          type     = "http"
          delay    = 10
          retries  = 3
          interval = 30
          timeout  = 2
          http = {
            port = 3000
            path = "/robots.txt"
          }
        },
        {
          type     = "http"
          retries  = 3
          interval = 10
          timeout  = 1
          teardown = true
          http = {
            port = 3000
          }
        }
      ]
    }
  ]
}

output "context" {
  value = module.this.context
}

output "refer" {
  value = nonsensitive(module.this.refer)
}

output "connection" {
  value = module.this.connection
}

output "address" {
  value = module.this.address
}

output "ports" {
  value = module.this.ports
}

output "endpoints" {
  value = module.this.endpoints
}
