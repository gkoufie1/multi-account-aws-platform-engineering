variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}


variable "force_destroy" {
  description = "Delete all objects (including old versions) when the bucket is destroyed."
  type        = bool
  default     = false
}
