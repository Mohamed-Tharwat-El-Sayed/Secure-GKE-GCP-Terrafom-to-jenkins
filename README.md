# Secure-GKE-GCP-Terrafom-to-jenkins
## Project Info.

This project contains:
*  Infrastructure as code using [Terraform](https://www.terraform.io/) that builds an environment on the google cloud platform
* Demo app with Dockerfile
* [Kubernetes](https://kubernetes.io) YAML files for deploying jenkins from secure cluster

## Tools Used

<p align="center">
<a href="https://www.terraform.io/" target="_blank" rel="noreferrer"> <img src="https://raw.githubusercontent.com/AbdEl-RahmanKhaled/AbdEl-RahmanKhaled/main/icons/terraform/terraform-original-wordmark.svg" alt="terraform" width="40" height="40"/> </a> <a href="https://cloud.google.com" target="_blank" rel="noreferrer"> <img src="https://raw.githubusercontent.com/AbdEl-RahmanKhaled/AbdEl-RahmanKhaled/main/icons/googlecloud/googlecloud-original.svg" alt="gcp" width="40" height="40"/> </a> <a href="https://kubernetes.io" target="_blank" rel="noreferrer"> <img src="https://raw.githubusercontent.com/AbdEl-RahmanKhaled/AbdEl-RahmanKhaled/main/icons/kubernetes/kubernetes-icon.svg" alt="kubernetes" width="40" height="40"/> </a> <a href="https://www.python.org" target="_blank" rel="noreferrer"> <img src="https://raw.githubusercontent.com/cncf/landscape/ec644e2bdc10390202c24bb33efaa7b137a00e1d/hosted_logos/jenkins.svg" alt="python" width="40" height="40"/> </a>
</p>

## Get Started

### Get The Code 
* Using [Git](https://git-scm.com/), clone the project.

    ```
    git clone https://github.com/Msbian/Secure-GKE-GCP-Terrafom-to-jenkins.git
    ```
###  Setup Infra 
* First setup your GCP account, create new project and change the value of "project_name" variable in Infra-GCP/dev.tfvars with your PROJECT-ID,if you host you con unhashed Infra-GCP/create-project.tf and create billing account and project by terraform

* Second build the infrastructure by run

    ```bash
    cd Infra-GCP/
    ```
    ``` 
    terraform init
    terraform apply --var-file dev.tfvars
    ```
    that will build:
    
    * VPC named "vpc-network"
    * 2 Subnets "management-sub", "restricted-sub"
    * Service Account
        * "gke-sa" used by Kubernetes cluster $ Management VM and in jenkins 

    * NAT in "management-sub"
    * Private Virtual Machine in "restrict-sub" subnet to manage the cluster .
    * public Virtual Machine in "mangement-sub" subnet to manage ansible and connect to private vm and deploy jenkins through playbook .
    * Private Kubernetes cluster in "restricted-sub" with 1 worker nodes.

    you can change some variables values in "terraform/dev.tfvars"
    
   ![terraform](https://user-images.githubusercontent.com/88733748/219639530-aa041846-8a49-48fc-bc11-8fd931c1c034.png)
   
### Deploy
* After the infrastructure got built, 
 * 1- now you can login to the "jenkins-vm" VM using SSH ( copy output of terraform ) then:
    
    *  through  installation.sh or manually (change service account and project in script)
          * install gcloud 
          * Install kubectl
          * Install gcloud plugin

    * setup cluster credentials
        ```
        gcloud container clusters get-credentials app-cluster --zone europe-west1-b --project <PROJECT-ID>
        vi /home/dep-ser.yaml `copy jenkins-files`
        ```
    * In jenkins-vm
      ```
      sudo su 
      passwd root
      vi /etc/ssh/sshd_config
      `PermitRootLogin yes`
      `PasswordAuthentication yes`
      service restart sshd
      ```
      ![1](https://user-images.githubusercontent.com/88733748/219640730-284d5cc3-34c7-4719-8000-2cc0efb4be58.png)
      
 * 2-  you can login to the "ansible-vm" VM using SSH  then:
    
    *  through  my script or manually
          * install ansible
          
    * In ansible-vm
      ```
      sudo su 
      ssh-keygen
      ssh-copy-id root@<private-ip-for-jenkins-vm>
      vi /etc/ansible/hosts `write private-ip-for-jenkins-vm`
      vi /home/ansible.yaml `write my ansible file`
      ansible-playbook /home/ansible.yaml
      ```
      ![8-ansible-playbook-run](https://user-images.githubusercontent.com/88733748/219640982-fea97e38-fd84-497b-a713-3098f9ff28a9.png)
      
        that will deploy in jenkins-vm:
        * jenkins Deployment and Exopse it with loadbalancer service in namespace jenkins
         ```
         sudo kubectl get svc -n jenkins
         ```
         ```
         kubectl exec -n jenkins -it svc/jenkins-service -c jenkins -- /bin/cat /var/jenkins_home/secrets/initialAdminPassword && echo
         ```
         ![9-jenkins-on-browser](https://user-images.githubusercontent.com/88733748/219641255-28a3cf20-8d4f-4ea0-ac1c-f6604dc9d5d1.png)
---
Now, you can access jenkins form [HERE](http://35.187.162.20:8080/login?from=%2F) 
