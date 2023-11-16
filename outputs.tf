output "context" {
  description = "The input context, a map, which is used for orchestration."
  value       = var.context
}

output "selector" {
  description = "The selector, a map, which is used for dependencies or collaborations."
  value       = local.labels
}

output "endpoint_internal" {
  description = "The internal endpoints, a string list, which are used for internal access."
  value = [
    for c in local.external_ports : format("%s.%s.svc.%s:%d", local.resource_name, local.namespace, local.domain_suffix, c.external)
  ]
}
