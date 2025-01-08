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

resource "google_compute_instance" "default" {
  name         = var.machine_name
  machine_type = var.machine_type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = var.machine_image
    }
  }

  network_interface {
    network = "default"
    access_config {}
  }

  metadata_startup_script = file("startup_script.sh")

  tags = ["http-server", "https-server"]

##  service_account {
##    email  = "default"
##    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
##  }

}