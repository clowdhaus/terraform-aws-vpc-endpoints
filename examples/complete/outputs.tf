output "gateway_endpoints" {
  description = "Array containing the full resource object and attributes for all gateway endpoints created"
  value       = module.endpoints.gateway_endpoints
}

output "interface_endpoints" {
  description = "Array containing the full resource object and attributes for all interface endpoints created"
  value       = module.endpoints.interface_endpoints
}

# Example looking up service/attribute
output "s3_endpoint_arn" {
  description = "S3 gateway endpoint ARN"
  value       = module.endpoints.gateway_endpoints["s3"].arn
}
