locals {
  hosts = [
    format("%s.%s.svc.%s", local.resource_name, local.namespace, local.domain_suffix)
  ]

  endpoints = length(local.external_ports) > 0 ? flatten([
    for c in local.hosts : formatlist("%s:%d", c, local.external_ports[*].external)
  ]) : []
}

#
# Orchestration
#

output "context" {
  description = "The input context, a map, which is used for orchestration."
  value       = var.context
}

output "refer" {
  description = "The refer, a map, including hosts, ports and account, which is used for dependencies or collaborations."
  sensitive   = true
  value = {
    schema = "k8s:deployment"
    params = {
      selector  = local.labels
      namespace = local.namespace
      name      = kubernetes_deployment_v1.deployment.metadata[0].name
      hosts     = local.hosts
      ports     = length(local.external_ports) > 0 ? local.external_ports[*].external : []
      endpoints = local.endpoints
    }
  }
}

#
# Reference
#

output "connection" {
  description = "The connection, a string combined host and port, might be a comma separated string or a single string."
  value       = join(",", local.endpoints)
}

output "address" {
  description = "The address, a string only has host, might be a comma separated string or a single string."
  value       = join(",", local.hosts)
}

output "ports" {
  description = "The port list of the service."
  value       = length(local.external_ports) > 0 ? local.external_ports[*].external : []
}

## UI display

output "endpoints" {
  description = "The endpoints, a list of string combined host and port."
  value       = local.endpoints
}
