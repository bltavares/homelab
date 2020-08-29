variable "zerotier_member" {
  type = object({
    name           = string
    node_id        = string,
    assignment_ips = list(string)
  })
}

variable "zerotier_network_id" {
  type = string
}

variable "zone_id" {
  type = string
}
