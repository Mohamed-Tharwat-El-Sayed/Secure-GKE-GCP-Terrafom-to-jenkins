resource "google_compute_instance" "ansible-vm" {
  name         = "ansible"
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
    subnetwork = module.network.out_management_subnet_name

  }
  
  metadata_startup_script = <<EOF
    sudo apt-get update -y
    sudo apt-add-repository ppa:ansible/ansible
    sudo apt-get update -y
    sudo apt-get install ansible -y
    sudo apt-get install python -y
    python --version
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
