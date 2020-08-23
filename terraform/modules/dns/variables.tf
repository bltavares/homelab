variable "zone_id" {
  type = string
}

variable "zt_addresses" {
  type = object({
    zt6plane_address = string,
    rfc4193_address  = string,
    ipv4_assignments = list(string)
  })
}

variable "domain" {
  type = string
}
