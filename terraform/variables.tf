variable "organization_root_id" {
  description = "AWS Organizations root ID for the target lab organization."
  type        = string
}

variable "development_ou_id" {
  description = "Development OU ID in the target lab organization."
  type        = string
}

variable "production_ou_id" {
  description = "Production OU ID in the target lab organization."
  type        = string
}

variable "sandbox_ou_id" {
  description = "Sandbox OU ID in the target lab organization."
  type        = string
}