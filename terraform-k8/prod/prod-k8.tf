

provider "helm" {
  debug =  true  
  kubernetes {
    config_context = "minikube"
    config_path = "~/.kube/config"
  }
  
}

resource "helm_release" "nginx" {
  name       = "prod-nginx"
  namespace  = "prod"
  atomic = true
  chart      = "../../abat-chart/nginx-chart"
  values = [
    "${file("prod-nginx-values.yaml")}"
  ]
  create_namespace = true
}

resource "helm_release" "url_shortener" {
  name       = "prod-url-shortener"
  atomic = true
  namespace  = "prod"
  chart      = "../../abat-chart/url-shortener-chart"
  values = [
    "${file("prod-url-shortener-values.yaml")}"
  ]
  create_namespace = true
}