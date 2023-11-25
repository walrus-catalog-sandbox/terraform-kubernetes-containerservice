# Kubernetes Container Service

Terraform module which deploys container service on Kubernetes.

## Usage

```hcl
module "example" {
  source = "..."

  infrastructure = {
    namespace = "default"
  }

  deployment = {
    timeout  = 30                     # in seconds
    replicas = 1
    rolling = {
      max_surge       = 0.25         # 0 < max_surge < 1
      max_unavailable = 0.25         # 0 < max_unavailable < 1
    }
  }

  containers = [
    {
      image     = "nginx:alpine"
      resources = {
        cpu    = 0.1
        memory = 100                 # in megabyte
      }
      ports = [
        {
          internal = 80
          external = 80
        }
      ]
      checks = [
        {
          delay = 10
          type  = "http"
          http = {
            port = 80
          }
        }
        {
          delay    = 10
          teardown = true
          type     = "http"
          http = {
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
- [Grafana](./examples/grafana)
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
| [kubernetes_config_map_v1.ephemeral_files](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/config_map_v1) | resource |
| [kubernetes_deployment_v1.deployment](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/deployment_v1) | resource |
| [kubernetes_service_v1.service](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service_v1) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_context"></a> [context](#input\_context) | Receive contextual information. When Walrus deploys, Walrus will inject specific contextual information into this field.<br><br>Examples:<pre>context:<br>  project:<br>    name: string<br>    id: string<br>  environment:<br>    name: string<br>    id: string<br>  resource:<br>    name: string<br>    id: string</pre> | `map(any)` | `{}` | no |
| <a name="input_infrastructure"></a> [infrastructure](#input\_infrastructure) | Specify the infrastructure information for deploying.<br><br>Examples:<pre>infrastructure:<br>  namespace: string, optional<br>  gpu_vendor: string, optional<br>  domain_suffix: string, optional<br>  service_type: string, optional</pre> | <pre>object({<br>    namespace     = optional(string)<br>    gpu_vendor    = optional(string, "nvidia.com")<br>    domain_suffix = optional(string, "cluster.local")<br>    service_type  = optional(string, "NodePort")<br>  })</pre> | `{}` | no |
| <a name="input_deployment"></a> [deployment](#input\_deployment) | Specify the deployment action, like scaling, scheduling, security and so on.<br><br>Examples:<pre>deployment:<br>  timeout: number, optional<br>  replicas: number, optional<br>  rolling: <br>    max_surge: number, optional          # in fraction, i.e. 0.25, 0.5, 1<br>    max_unavailable: number, optional    # in fraction, i.e. 0.25, 0.5, 1<br>  fs_group: number, optional<br>  sysctls:<br>  - name: string<br>    value: string</pre> | <pre>object({<br>    timeout  = optional(number, 300)<br>    replicas = optional(number, 1)<br>    rolling = optional(object({<br>      max_surge       = optional(number, 0.25)<br>      max_unavailable = optional(number, 0.25)<br>    }))<br>    fs_group = optional(number)<br>    sysctls = optional(list(object({<br>      name  = string<br>      value = string<br>    })))<br>  })</pre> | <pre>{<br>  "replicas": 1,<br>  "rolling": {<br>    "max_surge": 0.25,<br>    "max_unavailable": 0.25<br>  },<br>  "timeout": 300<br>}</pre> | no |
| <a name="input_containers"></a> [containers](#input\_containers) | Specify the container items to deploy.<br><br>Examples:<pre>containers:<br>- profile: init/run<br>  image: string<br>  execute:<br>    working_dir: string, optional<br>    command: list(string), optional<br>    args: list(string), optional<br>    readonly_rootfs: bool, optional<br>    as_user: number, optional<br>    as_group: number, optional<br>  resources:<br>    cpu: number, optional               # in oneCPU, i.e. 0.25, 0.5, 1, 2, 4<br>    memory: number, optional            # in megabyte<br>    gpu: number, optional               # in oneGPU, i.e. 1, 2, 4<br>  envs:<br>  - name: string<br>    value: string, optional             # accpet changed and restart<br>    value_refer:                        # donot accpet changed<br>      schema: string<br>      params: map(any)<br>  files:<br>  - path: string<br>    mode: string, optional<br>    content: string, optional           # accpet changed but not restart<br>    content_refer:                      # donot accpet changed<br>      schema: string<br>      params: map(any)<br>  mounts:<br>  - path: string<br>    readonly: bool, optional<br>    subpath: string, optional<br>    volume: string, optional            # shared between containers if named, otherwise exclusively by this container<br>    volume_refer:<br>      schema: string<br>      params: map(any)<br>  ports:<br>  - internal: number<br>    external: number, optional<br>    protocol: tcp/udp/sctp<br>  checks:<br>  - type: execute/tcp/grpc/http/https<br>    delay: number, optional<br>    interval: number, optional<br>    timeout: number, optional<br>    retries: number, optional<br>    teardown: bool, optional<br>    execute:<br>      command: list(string)<br>    tcp:<br>      port: number<br>    grpc:<br>      port: number<br>      service: string, optional<br>    http:<br>      port: number<br>      headers: map(string), optional<br>      path: string, optional<br>    https:<br>      port: number<br>      headers: map(string), optional<br>      path: string, optional</pre> | <pre>list(object({<br>    profile = optional(string, "run")<br>    image   = string<br>    execute = optional(object({<br>      working_dir     = optional(string)<br>      command         = optional(list(string))<br>      args            = optional(list(string))<br>      readonly_rootfs = optional(bool, false)<br>      as_user         = optional(number)<br>      as_group        = optional(number)<br>    }))<br>    resources = optional(object({<br>      cpu    = optional(number, 0.25)<br>      memory = optional(number, 256)<br>      gpu    = optional(number)<br>    }))<br>    envs = optional(list(object({<br>      name  = string<br>      value = optional(string)<br>      value_refer = optional(object({<br>        schema = string<br>        params = map(any)<br>      }))<br>    })))<br>    files = optional(list(object({<br>      path    = string<br>      mode    = optional(string, "0644")<br>      content = optional(string)<br>      content_refer = optional(object({<br>        schema = string<br>        params = map(any)<br>      }))<br>    })))<br>    mounts = optional(list(object({<br>      path     = string<br>      readonly = optional(bool, false)<br>      subpath  = optional(string)<br>      volume   = optional(string)<br>      volume_refer = optional(object({<br>        schema = string<br>        params = map(any)<br>      }))<br>    })))<br>    ports = optional(list(object({<br>      internal = number<br>      external = optional(number)<br>      protocol = optional(string, "tcp")<br>    })))<br>    checks = optional(list(object({<br>      type     = string<br>      delay    = optional(number, 0)<br>      interval = optional(number, 10)<br>      timeout  = optional(number, 1)<br>      retries  = optional(number, 1)<br>      teardown = optional(bool, false)<br>      execute = optional(object({<br>        command = list(string)<br>      }))<br>      tcp = optional(object({<br>        port = number<br>      }))<br>      grpc = optional(object({<br>        port    = number<br>        service = optional(string)<br>      }))<br>      http = optional(object({<br>        port    = number<br>        headers = optional(map(string))<br>        path    = optional(string, "/")<br>      }))<br>      https = optional(object({<br>        port    = number<br>        headers = optional(map(string))<br>        path    = optional(string, "/")<br>      }))<br>    })))<br>  }))</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_context"></a> [context](#output\_context) | The input context, a map, which is used for orchestration. |
| <a name="output_refer"></a> [refer](#output\_refer) | The refer, a map, including hosts, ports and account, which is used for dependencies or collaborations. |
| <a name="output_connection"></a> [connection](#output\_connection) | The connection, a string combined host and port, might be a comma separated string or a single string. |
| <a name="output_address"></a> [address](#output\_address) | The address, a string only has host, might be a comma separated string or a single string. |
| <a name="output_ports"></a> [ports](#output\_ports) | The port list of the service. |
| <a name="output_endpoints"></a> [endpoints](#output\_endpoints) | The endpoints, a list of string combined host and port. |
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
