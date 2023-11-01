data "google_compute_image" "sles" {
  family  = var.image_family
  project = var.image_project
}
