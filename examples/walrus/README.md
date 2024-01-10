# Walrus Example

Deploy walrus stack by root module.

```bash
# setup infra
$ tf apply -auto-approve \
  -target=kubernetes_namespace_v1.example

# create service
$ tf apply -auto-approve
```

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

| Name | Source | Version |
|------|--------|---------|
| <a name="module_casdoor"></a> [casdoor](#module\_casdoor) | ../.. | n/a |
| <a name="module_postgres"></a> [postgres](#module\_postgres) | ../.. | n/a |
| <a name="module_redis"></a> [redis](#module\_redis) | ../.. | n/a |
| <a name="module_walrus"></a> [walrus](#module\_walrus) | ../.. | n/a |

## Resources

| Name | Type |
|------|------|
| [kubernetes_namespace_v1.example](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace_v1) | resource |

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_address"></a> [address](#output\_address) | n/a |
| <a name="output_connection"></a> [connection](#output\_connection) | n/a |
| <a name="output_context"></a> [context](#output\_context) | n/a |
| <a name="output_endpoints"></a> [endpoints](#output\_endpoints) | n/a |
| <a name="output_endpoints_casdoor"></a> [endpoints\_casdoor](#output\_endpoints\_casdoor) | n/a |
| <a name="output_endpoints_postgres"></a> [endpoints\_postgres](#output\_endpoints\_postgres) | n/a |
| <a name="output_endpoints_redis"></a> [endpoints\_redis](#output\_endpoints\_redis) | n/a |
| <a name="output_ports"></a> [ports](#output\_ports) | n/a |
| <a name="output_refer"></a> [refer](#output\_refer) | n/a |
<!-- END_TF_DOCS -->
