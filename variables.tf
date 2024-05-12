variable "iam_role_attach_cni_policy" {
  default = true
  type    = string
}
 variable "key_service_roles_for_autoscaling" {
  description = "List of IAM roles required for autoscaling and cluster services"
  type        = list(string)
  default     = null
}
variable "create_addon" {
  description = "Flag to indicate whether to create the addon"
  type        = bool
  default     = true  # Set the default value according to your requirements
}

