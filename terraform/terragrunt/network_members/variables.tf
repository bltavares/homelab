variable "cloudflare_email" {
  type = string
}

variable "cloudflare_token" {
  type = string
}

variable "zerotier_api_key" {
  type = string
}

variable "zerotier_members" {
  type = map(object({
    node_id        = string,
    assignment_ips = list(string)
  }))
}

variable "name" {
  type = string
}
