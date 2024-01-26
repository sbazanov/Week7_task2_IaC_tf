variable "GOOGLE_PROJECT" {
  type        = string
  default     = ""
  description = "GCP project to use"
}

variable "GOOGLE_REGION" {
  type        = string
  default     = ""
  description = "GCP region to use"
}

variable "GKE_NUM_NODES" {
  type        = number
  default     = "2"
  description = "Number of nodes"
}

variable "GKE_CLUSTER_NAME" {
  type        = string
  default     = ""
  description = "GKE cluster name"
