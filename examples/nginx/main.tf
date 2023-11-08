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

resource "kubernetes_namespace_v1" "infra" {
  metadata {
    name = "nginx-svc"
  }
}

module "this" {
  source = "../.."

  infrastructure = {
    namespace = kubernetes_namespace_v1.infra.metadata[0].name
  }

  configs = [
    {
      name = "index-html"
      type = "data"
      data = {
        "index.html" = <<-EOF
<html>
  <h1>Hi</h1>
  </br>
  <h1>Welcome to Kubernetes Container Service.</h1>
</html
EOF
      }
    }
  ]

  containers = [
    {
      name = "nginx"
      image = {
        name        = "nginx:alpine"
        pull_policy = "IfNotPresent"
      }
      resources = {
        requests = {
          cpu    = 0.1
          memory = 100 # in megabyte
        }
      }
      mounts = [
        {
          path = "/usr/share/nginx/html"
          type = "config"
          config = {
            name            = "index-html"
            disable_changed = true
          }
        }
      ]
      ports = [
        {
          internal = 80
          protocol = "tcp"
        }
      ]
      checks = [
        {
          initial_delay = 10
          type          = "request"
          request = {
            protocol = "http"
            headers = {
              "x-request-id" = "test"
            }
            port = 80
          }
        },
        {
          teardown_unhealthy = true
          type               = "request"
          request = {
            port = 80
          }
        }
      ]
    }
  ]
}

output "context" {
  value = module.this.context
}

output "selector" {
  value = module.this.selector
}

output "endpoint_internal" {
  value = module.this.endpoint_internal
}
