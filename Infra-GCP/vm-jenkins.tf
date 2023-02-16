
resource "google_compute_instance" "management-vm" {
  name         = var.vm_name
  machine_type = var.vm_machine
  zone         = "${module.network.out_region}-b"
 
    
  boot_disk {
    initialize_params {
      image = var.vm_image
      type  = "pd-standard"
      size  = 30
    }
  }

  service_account {
    email  = google_service_account.gke_sa.email
    scopes = ["cloud-platform"]    #to access all of google cloud apis
  }
   
  network_interface {
    network    = module.network.out_vpc_name
    subnetwork = module.network.out_restricted_subnet_name

  }
  
  metadata_startup_script = <<EOF
    sudo apt update -y
    echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
    sudo apt install google-cloud-cli -y
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    curl -LO "https://dl.k8s.io/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"
    echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
    sudo chmod +x kubectl
    sudo mkdir -p ~/.local/bin
    sudo mv ./kubectl ~/.local/bin/kubectl
    sudo apt install google-cloud-sdk-gke-gcloud-auth-plugin
    sudo gcloud container clusters get-credentials app-cluster --zone europe-west1-b --project mohamed-tharwat-project
    echo "succefully..." > tmm.txt
  EOF



  depends_on = [
    google_container_cluster.app_cluster
   , google_container_node_pool.nodepool
  ]
  


#    lifecycle {
#     create_before_destroy = true
# }

}
