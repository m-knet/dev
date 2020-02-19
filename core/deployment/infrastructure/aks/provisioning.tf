provider "helm" {
}

data "helm_repository" "stable" {
  name = "stable"
  url  = "https://kubernetes-charts.storage.googleapis.com/"
}

resource "helm_release" "nginx_ingress" {
  name       = "ingress"
  namespace  = "ingress-basic"
  repository = data.helm_repository.stable.metadata[0].name
  chart      = "stable/nginx-ingress"
  version    = "1.29.5"

  values = [
    "${file("provisioning/ingress.yaml")}"
  ]
}

resource "helm_release" "prometheus" {
  name       = "prometheus"
  namespace  = "monitor"
  repository = data.helm_repository.stable.metadata[0].name
  chart      = "stable/prometheus"
  version    = "10.3.1"
}

resource "helm_release" "grafana" {
  name       = "grafana"
  namespace  = "monitor"
  repository = data.helm_repository.stable.metadata[0].name
  chart      = "stable/grafana"
  version    = "4.4.0"
}