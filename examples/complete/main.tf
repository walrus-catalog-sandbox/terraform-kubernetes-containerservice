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
    name = "complete-svc"
  }
}

resource "kubernetes_secret_v1" "example" {
  metadata {
    namespace = kubernetes_namespace_v1.example.metadata[0].name
    name      = "example"
  }

  data = {
    "secret1" = "secret1"
  }
}

resource "kubernetes_config_map_v1" "example" {
  metadata {
    namespace = kubernetes_namespace_v1.example.metadata[0].name
    name      = "example"
  }

  data = {
    "configmap1" = "this is refer file"
  }
}

resource "kubernetes_persistent_volume_claim_v1" "example" {
  wait_until_bound = false

  metadata {
    namespace = kubernetes_namespace_v1.example.metadata[0].name
    name      = "example"
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
    namespace = kubernetes_namespace_v1.example.metadata[0].name
  }

  deployment = {
    timeout  = 30
    replicas = 1
  }

  containers = [
    #
    # Init Container
    #
    {
      profile = "init"
      image   = "alpine"
      execute = {
        working_dir = "/"
        command = [
          "sh",
          "-c",
          "echo \"$${ENV1}:$${ENV2}\" >> /var/run/dir2/logs.txt; cat /var/run/dir2/logs.txt"
        ]
      }
      envs = [
        {
          name  = "ENV1"
          value = "env1" # accpet changed and restart
        },
        {
          name = "ENV2"
          value_refer = { # donot accpet changed
            schema = "k8s:secret"
            params = {
              name = "example"
              key  = "secret1"
            }
          }
        },
        { # invalid
          name = "ENV3"
        },
        { # invalid
          name  = "ENV4"
          value = ""
          value_refer = {
            schema = "k8s:secret"
            params = {
              name = "example"
              key  = "secret1"
            }
          }
        },
        { # invalid schema
          name = "ENV5"
          value_refer = {
            schema = "secret"
            params = {
              name = "example"
              key  = "secret1"
            }
          }
        },
        { # invalid schema
          name = "ENV6"
          value_refer = {
            schema = "k8s:configmap"
            params = {
              name = "example"
              key  = "configmap1"
            }
          }
        },
        { # invalid params
          name = "ENV7"
          value_refer = {
            schema = "k8s:configmap"
            params = {
              name = "example"
            }
          }
        }
      ]
      files = [
        { # ephemeral
          path    = "/var/run/config/file1"
          content = "this is ephemeral file" # accept changed but not restart
        },
        {                                      # refer
          path = "/var/run/config-refer/file2" # donot accpet changed
          content_refer = {
            schema = "k8s:configmap"
            params = {
              name = "example"
              key  = "configmap1"
            }
          }
        },
        { # invalid
          path = "/var/run/config/file3"
        },
        { # invalid
          path    = "/var/run/config/file4"
          content = "this is ephemeral file"
          content_refer = {
            schema = "k8s:configmap"
            params = {
              name = "example"
              key  = "configmap1"
            }
          }
        },
        { # invalid schema
          path = "/var/run/config/file5"
          content_refer = {
            schema = "configmap"
            params = {
              name = "example"
              key  = "configmap1"
            }
          }
        },
        { # invalid params
          path = "/var/run/config/file6"
          content_refer = {
            schema = "k8s:configmap"
            params = {
              name = "example"
            }
          }
        }
      ]
      mounts = [
        {                        # ephemeral
          path = "/var/run/dir1" # exclusively by this container
        },
        { # ephemeral
          path   = "/var/run/dir2"
          volume = "data" # shared between containers
        },
        { # refer
          path = "/var/run/dir3"
          volume_refer = {
            schema = "k8s:configmap"
            params = {
              name = "example"
            }
          }
        },
        { # refer
          path = "/var/run/dir4"
          volume_refer = {
            schema = "k8s:persistentvolumeclaim"
            params = {
              name = kubernetes_persistent_volume_claim_v1.example.metadata[0].name
            }
          }
        },
        { # invalid
          path   = "/var/run/dir5"
          volume = "data"
          volume_refer = {
            schema = "k8s:configmap"
            params = {
              name = "example"
            }
          }
        },
        { # invalid schema
          path = "/var/run/dir6"
          volume_refer = {
            schema = "configmap"
            params = {
              name = "example"
            }
          }
        },
      ]
    },

    #
    # Run Container
    #
    {
      image = "nginx:alpine"
      resources = {
        cpu    = 1
        memory = 1024 # Mi
      }
      files = [
        {
          path    = "/usr/share/nginx/html/index.html"
          content = <<-EOF
<html>
  <h1>Hi</h1>
  </br>
  <h1>This is first running nginx.</h1>
</html>
EOF
        }
      ]
      ports = [
        {
          internal = 80
          protocol = "UDP"
        },
        { # override the previous one
          internal = 80
          protocol = "TCP"
        },
        {
          internal = 8080
          protocol = "TCP"
        }
      ]
      checks = [
        { # startup probe
          type  = "http"
          delay = 10
          http = {
            port = 80
          }
        },
        { # readiness probe
          type = "tcp"
          tcp = {
            port = 80
          }
        },
        { # liveness probe
          type     = "exec"
          teardown = true
          exec = {
            command = ["curl", "http://localhost"]
          }
        },
        { # invalid
          type = "exec"
          tcp = {
            port = 80
          }
        },
        null
      ]
    },
    {
      image = "nginx"
      envs = [
        {
          name  = "NGINX_PORT"
          value = "8080"
        },
        null
      ]
      files = [
        {
          path    = "/usr/share/nginx/html/index.html"
          content = <<-EOF
<html>
  <h1>Hi</h1>
  </br>
  <h1>This is second running nginx.</h1>
</html>
EOF
        },
        {
          path    = "/etc/nginx/templates/default.conf.template"
          content = <<-EOF
server {
  listen       $${NGINX_PORT};
  server_name  localhost;
  location / {
      root   /usr/share/nginx/html;
      index  index.html index.htm;
  }
  location = /50x.html {
      root   /usr/share/nginx/html;
  }
}
EOF
        },
        null
      ]
      mounts = [
        { # ephemeral
          path   = "/test"
          volume = "data" # shared between containers
        },
        { # refer
          path = "/pvc"
          volume_refer = {
            schema = "k8s:persistentvolumeclaim"
            params = {
              name = kubernetes_persistent_volume_claim_v1.example.metadata[0].name
            }
          }
        },
        null
      ]
      ports = [
        { # override the previous container's specification
          internal = 8080
          external = 80 # expose
          protocol = "TCP"
        },
        null
      ]
    },
    null
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
