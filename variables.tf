variable "dockerhub_credentials" {
  type        = string
  description = "DockerHub Username and Password to download Images"
}

variable "codestar_connector_credentials" {
  type        = string
  description = "ARN of AWS codestar connector to Github"
}

variable "env" {
  type        = string
  description = "Name of Envoronment (dev/test/prod)"
}

variable "region" {
  type        = string
  description = "Region to deploy AWS resources into"
}

variable "company" {
  type        = string
  description = "Name of the Owning Company"
}