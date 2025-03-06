terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "6.14.1"
    }
  }
}

provider "google" {
  credentials = file(var.credentials)
  project     = var.project
  region      = var.region
}

resource "google_compute_disk" "additional_disk" {
  name  = "${var.machine_name}-disk"
  type  = "pd-standard"
  zone  = var.zone
  size  = var.disk_size # Size in GB
}

resource "google_compute_instance" "default" {
  name         = var.machine_name
  machine_type = var.machine_type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = var.machine_image
      size  = var.boot_disk_size # Size in GB
    }
  }

  attached_disk {
    source = google_compute_disk.additional_disk.id
  }

  network_interface {
    network = "default"
    access_config {}
  }

  service_account {
    email  = var.service_account_email
    scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }

  metadata_startup_script = file("startup_script.sh")

  tags = ["ui-server"]

}