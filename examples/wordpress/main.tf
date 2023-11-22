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
    name = "wordpress-svc"
  }
}

resource "kubernetes_persistent_volume_claim_v1" "example" {
  wait_until_bound = false

  metadata {
    namespace = kubernetes_namespace_v1.example.metadata[0].name
    name      = "mysql-data"
  }

  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        "storage" = "20Gi"
      }
    }
  }
}

resource "kubernetes_secret_v1" "example" {
  metadata {
    namespace = kubernetes_namespace_v1.example.metadata[0].name
    name      = "mysql-secret"
  }

  data = {
    database = "wordpress"
    username = "myuser"
    password = "mypass"
  }
}

locals {
  volume_refer_database_data = {
    schema = "k8s:persistentvolumeclaim"
    params = {
      name = kubernetes_persistent_volume_claim_v1.example.metadata[0].name
    }
  }

  env_refer_database_name = {
    schema = "k8s:secret"
    params = {
      name = kubernetes_secret_v1.example.metadata[0].name
      key  = "database"
    }
  }
  env_refer_database_username = {
    schema = "k8s:secret"
    params = {
      name = kubernetes_secret_v1.example.metadata[0].name
      key  = "username"
    }
  }
  env_refer_database_password = {
    schema = "k8s:secret"
    params = {
      name = kubernetes_secret_v1.example.metadata[0].name
      key  = "password"
    }
  }
}

module "this" {
  source = "../.."

  infrastructure = {
    namespace = kubernetes_namespace_v1.example.metadata[0].name
  }

  containers = [
    {
      image = "mysql:8.0"
      envs = [
        {
          name        = "MYSQL_DATABASE"
          value_refer = local.env_refer_database_name
        },
        {
          name        = "MYSQL_USER"
          value_refer = local.env_refer_database_username
        },
        {
          name        = "MYSQL_PASSWORD"
          value_refer = local.env_refer_database_password
        },
        {
          name        = "MYSQL_ROOT_PASSWORD"
          value_refer = local.env_refer_database_password
        }
      ]
      mounts = [
        {
          path         = "/var/lib/mysql"
          volume_refer = local.volume_refer_database_data # persistent
        }
      ]
      ports = [
        {
          internal = 3306
        }
      ]
    },

    {
      image = "wordpress:6.3.2-apache"
      envs = [
        {
          name  = "WORDPRESS_DB_HOST"
          value = "127.0.0.1:3306"
        },
        {
          name        = "WORDPRESS_DB_NAME"
          value_refer = local.env_refer_database_name
        },
        {
          name        = "WORDPRESS_DB_USER"
          value_refer = local.env_refer_database_username
        },
        {
          name        = "WORDPRESS_DB_PASSWORD"
          value_refer = local.env_refer_database_password
        }
      ]
      mounts = [
        {
          path = "/var/www/html" # ephemeral
        }
      ]
      ports = [
        {
          internal = 80
          external = 80 # publish
          protocol = "tcp"
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
