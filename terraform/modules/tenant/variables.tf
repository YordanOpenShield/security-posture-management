# == Tenant Variables ==

variable "name" {
  description = "Name of the tenant"
  type        = string
}

# == Infrastructure Variables ==

variable "server_image" {
  description = "The image to use for the server"
  type        = string
  default     = "ubuntu-22.04"
}

variable "server_type" {
  description = "The type of server to create"
  type        = string
  default     = "cx32"  # 4 vCPU, 8 GB RAM
}

variable "server_location" {
  description = "The location to create the server in"
  type        = string
}

variable "volume_size" {
  description = "Size of the volume in GB"
  type        = number
  default     = 50
}