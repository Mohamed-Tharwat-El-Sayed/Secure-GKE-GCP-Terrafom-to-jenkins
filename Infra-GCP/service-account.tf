resource "google_service_account" "gke_sa" {
  account_id   = "gke-sa"
  display_name = "GKE Service Account " # service account for manage containers and manage storge 
}

# resource "google_service_account" "docker_gcr_sa" {
#   account_id   = "docker-gcr-sa"
#   display_name = "Docker GCR Service Account" #service account for manage storge 
# }