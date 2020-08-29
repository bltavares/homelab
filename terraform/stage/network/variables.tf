variable "zerotier_api_key" {
  type = string
}

variable "zerotier_network" {
  type = map(object({
    first  = string,
    last   = string,
    target = string,
  }))
}

variable "cloudflare_email" {
  type = string
}

variable "cloudflare_token" {
  type = string
}
