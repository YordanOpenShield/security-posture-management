terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.22"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.18"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.5.0"
    }
    cloudflare = {
      source = "cloudflare/cloudflare"
      version = "5.11.0"
    }
  }
}