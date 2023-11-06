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
    name = "complete-svc"
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

  credentials = [
    {
      name = "dockerhub"
      type = "image_registry"
      image_registry = {
        server   = "https://index.docker.io/v1/"
        username = "username"
        password = "password"
      }
    }
  ]

  configs = [
    {
      name = "data"
      type = "data"
      data = {
        "data-k1" = "data-v1"
      }
    },
    {
      name = "secret"
      type = "secret"
      secret = {
        "secret-k1" = "secret-v1"
      }
    },
    {
      name = "invalid-config"
      type = "data"
      secret = { # wrong config
        "secret-k1" = "secret-v1"
      }
    }
  ]

  storages = [
    {
      name = "empty"
      type = "empty"
      empty = {
        medium = "Memory"
      }
    },
    # {
    #   name = "nas"
    #   type = "nas"
    #   nas = {
    #     server = "nfs-service.storage"
    #     path   = "/"
    #   }
    # },
    # {
    #   name = "san-fc"
    #   type = "san"
    #   san = {
    #     fs_type = "ext4"
    #     type    = "fc"
    #     fc = {
    #       lun = 2
    #       wwns = [
    #         "500a0982991b8dc5",
    #         "500a0982891b8dc5"
    #       ]
    #     }
    #   }
    # },
    # {
    #   name = "san-iscsi"
    #   type = "san"
    #   san = {
    #     type = "iscsi"
    #     iscsi = {
    #       lun    = 2
    #       portal = "10.0.2.15:3260"
    #       iqn    = "iqn.2001-04.com.example:storage.kube.sys1.xyz"
    #     }
    #   }
    # },
    {
      name = "ephemeral"
      type = "ephemeral"
      ephemeral = {
        size = 1024 # 1Gi
      }
    },
    {
      name = "persistent"
      type = "persistent"
      persistent = {
        name = kubernetes_persistent_volume_claim_v1.infra_pv.metadata[0].name
      }
    },
    {
      name  = "invalid-storage"
      type  = "persistent"
      empty = {} # wrong config
    }
  ]

  containers = [
    {
      name    = "init-container"
      profile = "init" # init container
      image = {
        name = "alpine"
      }
      execute = {
        command = [
          "sh",
          "-c",
          "echo \"$${TEST}:$${TEST_X}\" >> /opt/logs.txt; cat /opt/logs.txt"
        ]
        working_dir = "/"
      }
      envs = [
        {
          name = "TEST"
          type = "text"
          text = {
            content = "logging"
          }
        },
        {
          name = "TEST_X"
          type = "config"
          config = {
            name = "data"
            key  = "data-k1"
          }
        }
      ]
      mounts = [
        {
          path = "/var/stg/empty"
          type = "storage"
          storage = {
            name = "empty"
          }
        },
        {
          path = "/opt"
          type = "storage"
          storage = {
            name = "ephemeral"
          }
        },
        {
          path = "/var/stg/persistent"
          type = "storage"
          storage = {
            name = "persistent"
          }
        }
      ]
    },
    {
      name = "run-container"
      image = {
        name = "grafana/grafana:latest"
      }
      execute = {
        as = "non_root"
      }
      resources = {
        requests = {
          cpu    = 0.25
          memory = 750 # Mi
        }
        limits = {
          cpu    = 1
          memory = 1024 # Mi
        }
      }
      envs = [
        {
          type = "config"
          config = {
            name = "data"
          }
        }
      ]
      ports = [
        {
          internal = 3000
        }
      ]
      mounts = [
        {
          path = "/var/cfg/data/k1_changed"
          type = "config"
          config = {
            name = "data"
            key  = "data-k1"
          }
        },
        {
          path = "/var/cfg/data/k1_changed_alias"
          type = "config"
          config = {
            name = "data"
            key  = "data-k1"
          }
        },
        {
          path = "/var/cfg/data/k1_nochanged"
          type = "config"
          config = {
            name            = "data"
            key             = "data-k1"
            disable_changed = true
          }
        },
        {
          path = "/var/cfg/secret"
          type = "config"
          config = {
            name = "secret"
          }
        }
      ]
      checks = [
        {
          initial_delay = 10
          retries       = 3
          interval      = 30
          timeout       = 2
          type          = "request"
          request = {
            protocol = "http"
            path     = "/robots.txt"
            port     = 3000
          }
        },
        {
          retries            = 3
          interval           = 10
          timeout            = 1
          teardown_unhealthy = true
          type               = "request"
          request = {
            protocol = "tcp"
            port     = 3000
          }
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
