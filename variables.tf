#
# Contextual Fields
#

variable "context" {
  description = <<-EOF
Receive contextual information. When Walrus deploys, Walrus will inject specific contextual information into this field.

Examples:
```
context:
  project:
    name: string
    id: string
  environment:
    name: string
    id: string
  resource:
    name: string
    id: string
```
EOF
  type        = map(any)
  default     = {}
}

#
# Infrastructure Fields
#

variable "infrastructure" {
  description = <<-EOF
Specify the infrastructure information for deploying.

Examples:
```
infrastructure:
  namespace: string, optional
  gpu_vendor: string, optional
```
EOF
  type = object({
    namespace  = optional(string)
    gpu_vendor = optional(string, "nvidia.com")
  })
  default = {}
}

#
# Deployment Fields
#

variable "deployment" {
  description = <<-EOF
Specify the deployment action, including scaling and scheduling.

Examples:
```
deployment:
  timeout: number, optional
  replicas: 1
  update_strategy:
    type: recreate/rolling       
    recreate: {}
    rolling: 
      max_surge: number, in fraction, i.e. 0.25, 0.5, 1
      max_unavailable: number, in fraction, i.e. 0.25, 0.5, 1
  system_controls:
  - name: string
    value: string
```
EOF
  type = object({
    timeout  = optional(number)
    replicas = optional(number, 1)
    update_strategy = optional(object({
      type     = optional(string, "rolling")
      recreate = optional(object({}))
      rolling = optional(object({
        max_surge       = optional(number, 0.25)
        max_unavailable = optional(number, 0.25)
      }))
    }))
    system_controls = optional(list(object({
      name  = string
      value = string
    })))
  })
  default = {
    timeout  = 0
    replicas = 1
    update_strategy = {
      type = "rolling"
      rolling = {
        max_surge       = 0.25
        max_unavailable = 0.25
      }
    }
  }
}

#
# Prerequisite Fields
#

variable "credentials" {
  description = <<-EOF
Specify the credential items to fetch private data, like an internal image registry.

Examples:
```
credentials:
- name: string                     # unique
  type: image_registry
  image_registry: 
    server: string
    username: string
    password: string
    email: string, optional
```
EOF
  type = list(object({
    name = string
    type = optional(string, "image_registry")
    image_registry = optional(object({
      server   = string
      username = string
      password = string
      email    = optional(string)
    }))
  }))
  default = []
}

variable "configs" {
  description = <<-EOF
Specify the configuration items to configure containers, either raw or sensitive data.

Examples:
```
configs:
- name: string                     # unique
  type: data                       # convert to config map
  data: 
    (key: string): string
- name: string
  type: secret                     # convert to secret
  secret:
    (key: string): string
```
EOF
  type = list(object({
    name   = string
    type   = optional(string, "data")
    data   = optional(map(string))
    secret = optional(map(string))
  }))
  default = []
}

variable "storages" {
  description = <<-EOF
Specify the storage items to mount containers.

Examples:
```
storages:
- name: string                     # unique
  type: empty                      # convert ot empty_dir volume
  empty:
    medium: string, optional
    size: number, optional         # in megabyte
- name: string
  type: nas                        # convert to nfs volume
  nas:
    read_only: bool, optional
    server: string
    path: string, optional
    username: string, optional
    password: string, optional
- name: string
  type: san                        # convert to fc or iscsi volume
  san:
    read_only: bool, optional
    fs_type: string, optional
    type: fc/iscsi
    fc: 
      lun: number
      wwns: list(string)
    iscsi
      lun: number, optional
      portal: string
      iqn: string
- name: string
  type: ephemeral                   # convert to ephemeral volume claim template
  ephemeral:
    class: string, optional
    access_mode: string, optional
    size: number, optional          # in megabyte
- name: string
  type: persistent                  # convert to persistent volume claim template
  persistent:
    read_only: bool, optional
    name: string                    # persistent volume claim name
```
EOF
  type = list(object({
    name = string
    type = optional(string, "empty")
    empty = optional(object({
      medium = optional(string)
      size   = optional(number)
    }))
    nas = optional(object({
      read_only = optional(bool, false)
      server    = string
      path      = optional(string, "/")
      username  = optional(string)
      password  = optional(string)
    }))
    san = optional(object({
      read_only = optional(bool, false)
      fs_type   = optional(string, "ext4")
      type      = string
      fc = optional(object({
        lun  = optional(number, 0)
        wwns = list(string)
      }))
      iscsi = optional(object({
        lun    = optional(number, 0)
        portal = string
        iqn    = string
      }))
    }))
    ephemeral = optional(object({
      class       = optional(string)
      access_mode = optional(string, "ReadWriteOnce")
      size        = number
    }))
    persistent = optional(object({
      read_only = optional(bool, false)
      name      = string
    }))
  }))
  default = []
}

#
# Main Fields
#

variable "containers" {
  description = <<-EOF
Specify the container items to deployment.

Examples:
```
containers:
- name: string                     # unique
  profile: init/run
  image:
    name: string
    pull_policy: string, optional
  execute:
    command: list(string), optional
    args: list(string), optional
    working_dir: string, optional
    as: string, optional       # i.e. non_root, user_id:group:id
  resources:
    requests:
      cpu: number, optional        # in oneCPU, i.e. 0.25, 0.5, 1, 2, 4, 8
      memory: number, optional     # in megabyte
      gpu: number, optional        # i.e. 0.25, 0.5, 1, 2, 4, 8
    limits:
      cpu: number, optioanl        # in oneCPU, i.e. 0.25, 0.5, 1, 2, 4, 8
      memory: number, optional     # in megabyte
      gpu: number, optional        # i.e. 0.25, 0.5, 1, 2, 4, 8
  envs:
  - name: string, optional         # only work if the config.key is null
    type: text/config
    text:
      content: string
    config:
      name: string
      key: string, optional
  mounts:
  - path: string                   # unique
    read_only: bool, optional
    type: config/storage
    config:
      name: string
      key: string, optional
      mode: string, optional
      disable_changed: bool, optional # only work if config.key is not null
    storage:
      name: string
      sub_path: string, optional
  ports:
  - internal: number
    external: number, optional
    protocol: udp/tcp
  checks:
  - initial_delay: number
    interval: number
    timeout: number
    retries: number
    teardown_unhealthy: bool
    type: execute/request
    execute:
      command: list(string)
    request:
      protocol: tcp/grpc/http/https
      port: string
      headers: map(string), optional
      path: string, optional
```
EOF
  type = list(object({
    name    = string
    profile = optional(string, "run")
    image = object({
      name        = string
      pull_policy = optional(string, "IfNotPresent")
    })
    execute = optional(object({
      command     = optional(list(string))
      args        = optional(list(string))
      working_dir = optional(string)
      as          = optional(string)
    }))
    resources = optional(object({
      requests = object({
        cpu    = optional(number, 0.1)
        memory = optional(number, 64)
        gpu    = optional(number, 0)
      })
      limits = optional(object({
        cpu    = optional(number, 0)
        memory = optional(number, 0)
        gpu    = optional(number, 0)
      }))
    }))
    envs = optional(list(object({
      name = optional(string)
      type = optional(string, "text")
      text = optional(object({
        content = string
      }))
      config = optional(object({
        name = string
        key  = optional(string)
      }))
    })))
    mounts = optional(list(object({
      path      = string
      read_only = optional(bool, false)
      type      = optional(string, "config")
      config = optional(object({
        name            = string
        key             = optional(string)
        mode            = optional(string, "0644")
        disable_changed = optional(bool, false)
      }))
      storage = optional(object({
        name     = string
        sub_path = optional(string)
      }))
    })))
    ports = optional(list(object({
      internal = number
      external = optional(number)
      protocol = optional(string, "tcp")
    })))
    checks = optional(list(object({
      initial_delay      = optional(number, 0)
      interval           = optional(number, 10)
      timeout            = optional(number, 1)
      retries            = optional(number, 1)
      teardown_unhealthy = optional(bool, false)
      type               = optional(string, "request")
      execute = optional(object({
        command = list(string)
      }))
      request = optional(object({
        protocol = optional(string, "http")
        port     = number
        headers  = optional(map(string))
        path     = optional(string)
      }))
    })))
  }))
}
