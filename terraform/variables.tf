variable "DOCKER_USERNAME" {
  description = "Docker Hub username"
  type        = string
  sensitive   = true
}

variable "DOCKER_PASSWORD" {
  description = "Docker Hub password"
  type        = string
  sensitive   = true
}
