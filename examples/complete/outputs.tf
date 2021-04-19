output "endpoints" {
  description = "Array containing the full resource object and attributes for all endpoints created"
  value       = module.endpoints.endpoints
}

# Example looking up service/attribute
output "s3_endpoint_arn" {
  description = "S3 gateway endpoint ARN"
  value       = module.endpoints.endpoints["s3"].arn
}
