################################################################################
# Gateway Endpoint(s)
################################################################################

data "aws_vpc_endpoint_service" "gateway" {
  for_each = var.gateway_endpoints

  service = each.value.service

  filter {
    name   = "service-type"
    values = ["Gateway"]
  }
}

resource "aws_vpc_endpoint" "gateway" {
  for_each = var.gateway_endpoints

  vpc_id            = var.vpc_id
  service_name      = data.aws_vpc_endpoint_service.gateway[each.value.service].service_name
  vpc_endpoint_type = "Gateway"

  route_table_ids = each.value.route_table_ids
  policy          = lookup(each.value, "policy", null)

  tags = merge(var.tags, lookup(each.value, "tags", {}))

  timeouts {
    create = lookup(var.timeouts, "create", "10m")
    update = lookup(var.timeouts, "update", "10m")
    delete = lookup(var.timeouts, "delete", "10m")
  }
}

################################################################################
# Interface Endpoint(s)
################################################################################

data "aws_vpc_endpoint_service" "interface" {
  for_each = var.interface_endpoints

  service      = lookup(each.value, "service", null)
  service_name = lookup(each.value, "service_name", null)
}

resource "aws_vpc_endpoint" "interface" {
  for_each = var.interface_endpoints

  vpc_id            = var.vpc_id
  service_name      = data.aws_vpc_endpoint_service.interface[each.key].service_name
  vpc_endpoint_type = "Interface"
  auto_accept       = try(var.auto_accept, lookup(each.value, "auto_accept", null), null)

  security_group_ids  = distinct(concat(var.security_group_ids, lookup(each.value, "security_group_ids", [])))
  subnet_ids          = distinct(concat(var.subnet_ids, lookup(each.value, "subnet_ids", [])))
  policy              = lookup(each.value, "policy", null)
  private_dns_enabled = lookup(each.value, "private_dns_enabled", null)

  tags = merge(var.tags, lookup(each.value, "tags", {}))

  timeouts {
    create = lookup(var.timeouts, "create", "10m")
    update = lookup(var.timeouts, "update", "10m")
    delete = lookup(var.timeouts, "delete", "10m")
  }
}
