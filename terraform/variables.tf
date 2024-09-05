variable "aws_access_key" {
  description = "The AWS access key"
  type        = string
  default     = ""
}

variable "aws_secret_key" {
  description = "The AWS secret key"
  type        = string
  default     = ""
}

variable "token" {
  description = "The AWS token"
  type        = string
  default     = ""
}
variable "aws_region" {
  description = "The AWS region to create Users"
  type        = string
  default     = ""
}
variable "thumbprint_list" {
  type        = list(string)
  description = "(optional) Thumbprint list"
  default     = []
}

/*
variable "eks_oidc_root_ca_thumbprint" {
    type = string
    description = "eks cluster root CA certificate"
    default = "d89e3bd43d5d909b47a18977aa9d5ce36cee184c"
}
*/
