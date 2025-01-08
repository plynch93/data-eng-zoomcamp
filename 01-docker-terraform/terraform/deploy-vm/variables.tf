## General
variable "credentials" {
  description = "My Credentials"
  default     = "~/keys/my-creds.json"
}

variable "project" {
  description = "Project"
  default     = "data-eng-446809"
}

variable "location" {
  description = "Project Location"
  default     = "AU"
}

variable "region" {
  description = "Region"
  default     = "australia-southeast1"
}

variable "zone" {
  description = "Zone"
  default = "australia-southeast1-b"
}

## Compute Instance - Vitual Machine
variable "machine_name" {
  description = "Name for virtual machine"
  default = "my-vm"
}

variable "machine_type" {
  description = "Machine type"
  default = "e2-small"
}

variable "machine_image" {
  description = "Machine image"
  default = "ubuntu-2204-jammy-v20241218"
}

## Big Query
variable "bq_dataset_name" {
  description = "My BigQuery Dataset Name"
  default     = "demo_dataset"
}

## Storage Bucket
variable "gcs_bucket_name" {
  description = "My Storage Bucket Name"
  default     = "data-eng-446809-demo-bucket"
}

variable "gcs_storage_class" {
  description = "Bucket Storage Class"
  default     = "STANDARD"
}