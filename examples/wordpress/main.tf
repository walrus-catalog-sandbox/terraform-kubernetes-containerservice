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
    name = "wordpress-svc"
  }
}

resource "kubernetes_persistent_volume_claim_v1" "infra_pv" {
  wait_until_bound = false

  metadata {
    namespace = kubernetes_namespace_v1.infra.metadata[0].name
    name      = "pv"
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

module "this" {
  source = "../.."

  infrastructure = {
    namespace = kubernetes_namespace_v1.infra.metadata[0].name
  }

  storages = [
    {
      name = "data"
      type = "persistent"
      persistent = {
        name = kubernetes_persistent_volume_claim_v1.infra_pv.metadata[0].name
      }
    },
    {
      name = "www"
      type = "empty"
      empty = {
        size = 20 * 1024 # in megabyte
      }
    }
  ]

  configs = [
    {
      name = "database"
      type = "secret"
      secret = {
        password = "wordpress"
        database = "wordpress"
        username = "wordpress"
      }
    }
  ]

  containers = [
    {
      name = "mysql"
      image = {
        name        = "mysql:8.2.0"
        pull_policy = "IfNotPresent"
      }
      envs = [
        {
          name = "MYSQL_ROOT_PASSWORD"
          type = "config"
          config = {
            name = "database"
            key  = "password"
          }
        },
        {
          name = "MYSQL_PASSWORD"
          type = "config"
          config = {
            name = "database"
            key  = "password"
          }
        },
        {
          name = "MYSQL_DATABASE"
          type = "config"
          config = {
            name = "database"
            key  = "database"
          }
        },
        {
          name = "MYSQL_USER"
          type = "config"
          config = {
            name = "database"
            key  = "username"
          }
        }
      ]
      mounts = [
        {
          path = "/var/lib/mysql"
          type = "storage"
          storage = {
            name = "data"
          }
        }
      ]
    },

    {
      name = "wordpress"
      image = {
        name        = "wordpress:6.3.2-apache"
        pull_policy = "Always"
      }
      envs = [
        {
          name = "WORDPRESS_DB_HOST"
          type = "text"
          text = {
            content = "wordpress-mysql"
          }
        },
        {
          name = "WORDPRESS_DB_PASSWORD"
          type = "config"
          config = {
            name = "database"
            key  = "password"
          }
        },
        {
          name = "WORDPRESS_DB_USER"
          type = "config"
          config = {
            name = "database"
            key  = "username"
          }
        }
      ]
      mounts = [
        {
          path = "/var/www/html"
          type = "storage"
          storage = {
            name = "www"
          }
        }
      ]
      ports = [
        {
          internal = 80
        }
      ]
    }
  ]
}

output "context" {
  value = module.this.context
}

output "endpoint_internal" {
  value = module.this.endpoint_internal
}
