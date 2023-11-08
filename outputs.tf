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
    for c in local.run_containers_ports : format("%s.%s.svc:%d", local.resource_name, local.namespace, c.external != null ? c.external : c.internal)
  ]
}
