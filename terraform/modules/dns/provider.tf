provider "cloudflare" {
  version = "~> 2.6"
  email   = var.cloudflare_email
  api_key = var.cloudflare_token
}
