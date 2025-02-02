variable "prefix" {
  description = "A prefix used for all resources in this example"
  default     = "Narendra-Candidate"
}

variable "location" {
  description = "The region used for this sbx"
  default     = "east-us"
}

variable "fwprivate_ip" {
  description = "The private IP address for internal traffic routing."
  default     = "10.1.1.5" # This needs to match the 
}

variable "fwpublic_ip" {
  description = "The public IP address for external traffic routing."
  default     = "192.167.255.250"
}
