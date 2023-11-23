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
    name = "nginx-svc"
  }
}

module "this" {
  source = "../.."

  infrastructure = {
    namespace = kubernetes_namespace_v1.example.metadata[0].name
  }

  deployment = {
    replicas = 2
    sysctls = [
      {
        name  = "net.ipv4.tcp_syncookies"
        value = "1"
      }
    ]
  }

  containers = [
    {
      image = "nginx:alpine"
      resources = {
        cpu    = 0.1
        memory = 100 # Mi
      }
      files = [
        {
          path    = "/usr/share/nginx/html/index.html"
          content = <<-EOF
<html>
  <h1>Hi</h1>
  </br>
  <h1>Welcome to Kubernetes Container Service.</h1>
</html>
EOF
        }
      ]
      ports = [
        {
          internal = 80
          external = 80 # publish
          protocol = "tcp"
        }
      ]
      checks = [
        {
          type  = "http"
          delay = 10
          http = {
            port = 80
          }
        },
        {
          type     = "http"
          teardown = true
          http = {
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
