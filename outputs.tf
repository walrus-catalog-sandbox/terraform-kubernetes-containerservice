output "context" {
  description = "The input context, a map, which is used for orchestration."
  value       = var.context
}

output "endpoint_internal" {
  description = "The internal endpoints, a string list, which are used for internal access."
  value = [
    for c in local.run_containers_ports : format("%s.%s:%d", local.resource_name, local.namespace, c.external != null ? c.external : c.internal)
  ]
}
