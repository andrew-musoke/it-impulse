# Welcome to StackEdit!

As per the functional requirements, the submission contains terraform scripts that deploy an Nginx server and a url-shortener application on a minikube cluster in two different environments.

## Assumptions
- Application service ports of 80 and 8080 refers to container ports
- These scripts will be run on a Linux machine with admin access.
- You have the latest versions of Minikube, Helm, Kubectl, Curl, Terraform and Linux 
- Your minikube cluster configuration is located at `~/.kube/config` and the context used is `minikube`
- `Dev` and `Prod` environments refers to namespaces.

## Prerequisites
Install and configure the following on your local machine.
- Ubuntu Linux version 22.04 LTS +
- Minikube v1.34.0 +
- Curl v8.7.1 +
- Terraform v1.9.3 +
- Helm v3.11.3 +
- Kubectl v1.23.6 +

## File structure
-   `abat-chart`  (Directory)
    -   `nginx-chart`  (Directory): Configuration files for the Nginx Helm chart.
        -   `Chart.yaml`  (File): Defines the Helm chart metadata.
        -   `templates`  (Directory): Contains template files for the Nginx deployment.
            -   `NOTES.txt`  (File): Documentation for the Nginx chart.
            -   `deployment.yaml`  (File): Deployment configuration for Nginx.
            -   `service.yaml`  (File): Service configuration for Nginx.
            -   `tests`  (Directory): Contains test configuration for Nginx deployment.
                -   `test-connection.yaml`  (File): Configuration for testing Nginx connectivity.
            -   `_helpers.tpl`  (File): Likely a template helper file used by other templates.
            -   `ingress.yaml`  (File): (Optional) Configuration for an ingress resource for Nginx.
            -   `serviceaccount.yaml`  (File): (Optional) Configuration for a service account for Nginx.
    -   `url-shortener-chart`  (Directory): Configuration files for the URL shortener Helm chart (Similar structure to  `nginx-chart`).
-   `terraform-k8`  (Directory): Configuration files for Terraform deployments on Kubernetes.
    -   `dev`  (Directory): Terraform configuration for a development Kubernetes cluster.
        -   `dev-k8.tf`  (File): The main Terraform configuration file for the development cluster.
        -   `providers.tf`  (File): Configuration for Terraform providers used in the development cluster.
        -   `terraform.tfstate`  (File): Terraform state file for the development cluster.
        -   `terraform.tfstate.backup`  (File): Backup of the development cluster's Terraform state.
        -   `dev-nginx-values.yaml`  (File): Custom helm values consumed by terraform during deployment
        -   `dev-url-shortener-values.yaml`  (File): Custom helm values consumed by terraform during deployment
    -   `prod`  (Directory): Terraform configuration for a production Kubernetes cluster (Similar structure to  `dev`).

> NOTE: The state and state backup will not appear in the directory because it is not best practice to have this on Github. They will be created during the steps below.


## Setup

1.  **Enable Ingress Addons:**  Ensure the  `ingress`  and  `ingress-dns`  addons are enabled on your Minikube cluster:
    
    ```
    minikube addons enable ingress
    minikube addons enable ingress-dns
    
2.  **Create Helm Charts:**
    To automatically deploy with Terraform, we need to create helm charts to modularise the process.
-   Created Helm charts for the Nginx and URL shortener applications.
```bash
cd abat-chart
helm create nginx-chart
helm create url-shortener-chart 
```
-   Customize the  `values.yaml`, `Chart.yaml`  and  `templates`  directory within each chart to define services and ingress resources for your applications.
3.  **Deploy with Terraform:**  Use Terraform to deploy the Helm charts to the respective environments (dev and prod).
- To ensure that the state is separate per environment, the terraform files are kept in separate folders labeled `dev` and `prod`
- Customise the terraform files to link to your kubernetes cluster.
```
kubernetes {
config_context  =  "minikube"
config_path  =  "~/.kube/config"
}
```
- Customise the terraform files to set the `host` url and the `port` per environment.
```
set {
name  =  "service.nodeport"
value  =  "30202"
}
set {
name  =  "ingress.hosts[0].host"
value  =  "nginx-prod.test"
}
``` 

5.  **Configure Ingress DNS:**
    
-   Follow the official [Minikube documentation](https://minikube.sigs.k8s.io/docs/handbook/addons/ingress-dns/#Linux) to configure ingress DNS.
    - Acquire your Minikube's IP address.
```
minikube ip
```  
- Add the Minikube IP address to your system's DNS resolution chain. For Linux, add your Minikube IP as a nameserver as per the documentation.

## Simplified Steps for Deployment and Cleanup

**Deployment:**
1. Enter the terraform directory. This is environment specific
`cd terraform-k8/dev`
2.  **Initialize Terraform:**  
Run  `terraform init`  
3.  **Apply Configuration:**  
Run  `terraform plan` to confirm the changes. 
Run  `terraform apply`  to deploy the Helm charts to Minikube.
4. **Access the services**
You can access the services in two ways; through the URL or through the IP and Port combination. Examples using the set defaults are below;

a. **Using URLs**
Prod environment
```
curl http://nginx-prod.test
curl http://url-shortener-prod.test
```
Dev environment
```
curl http://nginx-dev.test
curl http://url-shortener-dev.test
```
b. **Using IP:Port**
Prod environment
```bash
# url-shortener
curl http://$(minikube ip):30302
# ngnix
curl http://$(minikube ip):30202
```
Dev environment
```bash
# url-shortener
curl http://$(minikube ip):30301
# ngnix
curl http://$(minikube ip):30201
```

**Cleanup:**

To remove the deployed applications, run  `terraform destroy`.

## Notes

- The referenced `Nginx and URL-Shortener`  services were not made available so I used dummy containers from dockerhub as standins. The requirement for container ports 80 and 8080 are preserved.
- While separating files for each application is demonstrated here, it's unnecessary for smaller projects. It serves as an example of best practices for larger projects.
-   Minikube's default network limitations require using  `minikube service [service name] --url`  (for Mac) to access services through NodePort. Refer to the official documentation ([https://minikube.sigs.k8s.io/docs/handbook/accessing/#using-minikube-service-with-tunnel](https://minikube.sigs.k8s.io/docs/handbook/accessing/#using-minikube-service-with-tunnel)) for more information.