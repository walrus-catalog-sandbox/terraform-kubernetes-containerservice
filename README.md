# Kubernetes Container Service

Terraform module which deploys container service on Kubernetes.

## Usage

```hcl
module "example" {
  source = "..."

  infrastructure = {
    namespace = "default"
  }

  containers = [
    {
      name = "nginx"
      image = {
        name = "nginx:alpine"
        pull_policy = "Always"
      }
      resources = {
        requests = {
          cpu = 0.1
          memory = 100 # in megabyte
        }
      }
      ports = [
        {
          internal = 80
        }
      ]
      checks = [
        {
          initial_delay = 10
          type = "request"
          request = {
            protocol = "http"
            port = 80
          }
        }
      ]
    }
  ]
}
```

## Examples

- [Complete](./examples/complete)
- [Nginx](./examples/nginx)
- [WordPress](./examples/wordpress)

## Contributing

Please read our [contributing guide](./docs/CONTRIBUTING.md) if you're interested in contributing to Walrus template.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.23.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | >= 2.23.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [kubernetes_config_map_v1.configs](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/config_map_v1) | resource |
| [kubernetes_deployment_v1.deployment](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/deployment_v1) | resource |
| [kubernetes_secret_v1.configs](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret_v1) | resource |
| [kubernetes_secret_v1.image_registry_credentials](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret_v1) | resource |
| [kubernetes_service_v1.service](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service_v1) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_context"></a> [context](#input\_context) | Receive contextual information. When Walrus deploys, Walrus will inject specific contextual information into this field.<br><br>Examples:<pre>context:<br>  project:<br>    name: string<br>    id: string<br>  environment:<br>    name: string<br>    id: string<br>  resource:<br>    name: string<br>    id: string</pre> | `map(any)` | `{}` | no |
| <a name="input_infrastructure"></a> [infrastructure](#input\_infrastructure) | Specify the infrastructure information for deploying.<br><br>Examples:<pre>infrastructure:<br>  namespace: string, optional<br>  gpu_vendor: string, optional</pre> | <pre>object({<br>    namespace  = optional(string)<br>    gpu_vendor = optional(string, "nvidia.com")<br>  })</pre> | `{}` | no |
| <a name="input_deployment"></a> [deployment](#input\_deployment) | Specify the deployment action, like scaling, scheduling, security and so on.<br><br>Examples:<pre>deployment:<br>  timeout: number, optional<br>  replicas: 1<br>  update_strategy:<br>    type: recreate/rolling<br>    recreate: {}<br>    rolling: <br>      max_surge: number, in fraction, i.e. 0.25, 0.5, 1<br>      max_unavailable: number, in fraction, i.e. 0.25, 0.5, 1<br>  system_controls:<br>  - name: string<br>    value: string</pre> | <pre>object({<br>    timeout  = optional(number)<br>    replicas = optional(number, 1)<br>    update_strategy = optional(object({<br>      type     = optional(string, "rolling")<br>      recreate = optional(object({}), {})<br>      rolling = optional(object({<br>        max_surge       = optional(number, 0.25)<br>        max_unavailable = optional(number, 0.25)<br>      }))<br>    }))<br>    system_controls = optional(list(object({<br>      name  = string<br>      value = string<br>    })))<br>  })</pre> | <pre>{<br>  "replicas": 1,<br>  "timeout": 0,<br>  "update_strategy": {<br>    "rolling": {<br>      "max_surge": 0.25,<br>      "max_unavailable": 0.25<br>    },<br>    "type": "rolling"<br>  }<br>}</pre> | no |
| <a name="input_credentials"></a> [credentials](#input\_credentials) | Specify the credential items to fetch private data, like an internal image registry.<br><br>Examples:<pre>credentials:<br>- name: string                     # unique<br>  type: image_registry<br>  image_registry: <br>    server: string<br>    username: string<br>    password: string<br>    email: string, optional</pre> | <pre>list(object({<br>    name = string<br>    type = optional(string, "image_registry")<br>    image_registry = optional(object({<br>      server   = string<br>      username = string<br>      password = string<br>      email    = optional(string)<br>    }))<br>  }))</pre> | `[]` | no |
| <a name="input_configs"></a> [configs](#input\_configs) | Specify the configuration items to configure containers, either raw or sensitive data.<br><br>Examples:<pre>configs:<br>- name: string                     # unique<br>  type: data                       # convert to config map<br>  data: <br>    (key: string): string<br>- name: string<br>  type: secret                     # convert to secret<br>  secret:<br>    (key: string): string</pre> | <pre>list(object({<br>    name   = string<br>    type   = optional(string, "data")<br>    data   = optional(map(string))<br>    secret = optional(map(string))<br>  }))</pre> | `[]` | no |
| <a name="input_storages"></a> [storages](#input\_storages) | Specify the storage items to mount containers.<br><br>Examples:<pre>storages:<br>- name: string                     # unique<br>  type: empty                      # convert ot empty_dir volume<br>  empty:<br>    medium: string, optional<br>    size: number, optional         # in megabyte<br>- name: string<br>  type: nas                        # convert to in-tree nfs volume<br>  nas:<br>    read_only: bool, optional<br>    server: string<br>    path: string, optional<br>    username: string, optional<br>    password: string, optional<br>- name: string<br>  type: san                        # convert to in-tree fc or iscsi volume<br>  san:<br>    read_only: bool, optional<br>    fs_type: string, optional<br>    type: fc/iscsi<br>    fc: <br>      lun: number<br>      wwns: list(string)<br>    iscsi<br>      lun: number, optional<br>      portal: string<br>      iqn: string<br>- name: string<br>  type: ephemeral                   # convert to dynamic volume claim template<br>  ephemeral:<br>    class: string, optional<br>    access_mode: string, optional<br>    size: number, optional          # in megabyte<br>- name: string<br>  type: persistent                  # convert to existing volume claim template<br>  persistent:<br>    read_only: bool, optional<br>    name: string                    # the name of persistent volume claim</pre> | <pre>list(object({<br>    name = string<br>    type = optional(string, "empty")<br>    empty = optional(object({<br>      medium = optional(string)<br>      size   = optional(number)<br>    }))<br>    nas = optional(object({<br>      read_only = optional(bool, false)<br>      server    = string<br>      path      = optional(string, "/")<br>      username  = optional(string)<br>      password  = optional(string)<br>    }))<br>    san = optional(object({<br>      read_only = optional(bool, false)<br>      fs_type   = optional(string, "ext4")<br>      type      = string<br>      fc = optional(object({<br>        lun  = optional(number, 0)<br>        wwns = list(string)<br>      }))<br>      iscsi = optional(object({<br>        lun    = optional(number, 0)<br>        portal = string<br>        iqn    = string<br>      }))<br>    }))<br>    ephemeral = optional(object({<br>      class       = optional(string)<br>      access_mode = optional(string, "ReadWriteOnce")<br>      size        = number<br>    }))<br>    persistent = optional(object({<br>      read_only = optional(bool, false)<br>      name      = string<br>    }))<br>  }))</pre> | `[]` | no |
| <a name="input_containers"></a> [containers](#input\_containers) | Specify the container items to deployment.<br><br>Examples:<pre>containers:<br>- name: string                        # unique<br>  profile: init/run<br>  image:<br>    name: string<br>    pull_policy: string, optional<br>  execute:<br>    command: list(string), optional<br>    args: list(string), optional<br>    working_dir: string, optional<br>    as: string, optional              # i.e. non_root, user_id:group:id<br>  resources:<br>    requests:<br>      cpu: number, optional           # in oneCPU, i.e. 0.25, 0.5, 1, 2, 4, 8<br>      memory: number, optional        # in megabyte<br>      gpu: number, optional           # i.e. 0.25, 0.5, 1, 2, 4, 8<br>    limits:<br>      cpu: number, optioanl           # in oneCPU, i.e. 0.25, 0.5, 1, 2, 4, 8<br>      memory: number, optional        # in megabyte<br>      gpu: number, optional           # i.e. 0.25, 0.5, 1, 2, 4, 8<br>  envs:<br>  - name: string, optional            # only work if the config.key is null<br>    type: text/config<br>    text:<br>      content: string<br>    config:<br>      name: string<br>      key: string, optional<br>  mounts:<br>  - path: string                      # unique<br>    read_only: bool, optional<br>    type: config/storage<br>    config:<br>      name: string<br>      key: string, optional<br>      mode: string, optional<br>      disable_changed: bool, optional # only work if config.key is not null<br>    storage:<br>      name: string<br>      sub_path: string, optional<br>  ports:<br>  - internal: number<br>    external: number, optional<br>    protocol: udp/tcp<br>  checks:<br>  - initial_delay: number, optional<br>    interval: number, optional<br>    timeout: number, optional<br>    retries: number, optional<br>    teardown_unhealthy: bool, optional<br>    type: execute/request<br>    execute:<br>      command: list(string)<br>    request:<br>      protocol: tcp/grpc/http/https<br>      port: number<br>      headers: map(string), optional<br>      path: string, optional          # put GRPC service name if request.protocol is grpc</pre> | <pre>list(object({<br>    name    = string<br>    profile = optional(string, "run")<br>    image = object({<br>      name        = string<br>      pull_policy = optional(string, "IfNotPresent")<br>    })<br>    execute = optional(object({<br>      command     = optional(list(string))<br>      args        = optional(list(string))<br>      working_dir = optional(string)<br>      as          = optional(string)<br>    }))<br>    resources = optional(object({<br>      requests = object({<br>        cpu    = optional(number, 0.1)<br>        memory = optional(number, 64)<br>        gpu    = optional(number, 0)<br>      })<br>      limits = optional(object({<br>        cpu    = optional(number, 0)<br>        memory = optional(number, 0)<br>        gpu    = optional(number, 0)<br>      }))<br>    }))<br>    envs = optional(list(object({<br>      name = optional(string)<br>      type = optional(string, "text")<br>      text = optional(object({<br>        content = string<br>      }))<br>      config = optional(object({<br>        name = string<br>        key  = optional(string)<br>      }))<br>    })))<br>    mounts = optional(list(object({<br>      path      = string<br>      read_only = optional(bool, false)<br>      type      = optional(string, "config")<br>      config = optional(object({<br>        name            = string<br>        key             = optional(string)<br>        mode            = optional(string, "0644")<br>        disable_changed = optional(bool, false)<br>      }))<br>      storage = optional(object({<br>        name     = string<br>        sub_path = optional(string)<br>      }))<br>    })))<br>    ports = optional(list(object({<br>      internal = number<br>      external = optional(number)<br>      protocol = optional(string, "tcp")<br>    })))<br>    checks = optional(list(object({<br>      initial_delay      = optional(number, 0)<br>      interval           = optional(number, 10)<br>      timeout            = optional(number, 1)<br>      retries            = optional(number, 1)<br>      teardown_unhealthy = optional(bool, false)<br>      type               = optional(string, "request")<br>      execute = optional(object({<br>        command = list(string)<br>      }))<br>      request = optional(object({<br>        protocol = optional(string, "http")<br>        port     = number<br>        headers  = optional(map(string))<br>        path     = optional(string)<br>      }))<br>    })))<br>  }))</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_context"></a> [context](#output\_context) | The input context, a map, which is used for orchestration. |
| <a name="output_endpoint_internal"></a> [endpoint\_internal](#output\_endpoint\_internal) | The internal endpoints, a string list, which are used for internal access. |
<!-- END_TF_DOCS -->

## License

Copyright (c) 2023 [Seal, Inc.](https://seal.io)

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at [LICENSE](./LICENSE) file for details.

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
