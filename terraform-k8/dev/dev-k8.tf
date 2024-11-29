

provider "helm" {
  debug =  true  
  kubernetes {
    config_context = "minikube"
    config_path = "~/.kube/config"
  }
  
}

resource "helm_release" "nginx" {
  name       = "dev-nginx"
  namespace  = "dev"
  atomic = true
  chart      = "../../abat-chart/nginx-chart"
  values = [
    "${file("dev-nginx-values.yaml")}"
  ]
  create_namespace = true
}

resource "helm_release" "url_shortener" {
  name       = "dev-url-shortener"
  atomic = true
  namespace  = "dev"
  chart      = "../../abat-chart/url-shortener-chart"
  values = [
    "${file("dev-url-shortener-values.yaml")}"
  ]
  create_namespace = true
}