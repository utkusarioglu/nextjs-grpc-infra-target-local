resource "helm_release" "ingress" {
  count      = 1
  name       = "ingress"
  chart      = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  version    = "4.2.5"

  values = [
    yamlencode({
      controller = {

        metrics = {
          enabled = true
        }
        ingressClass = "public"
        ingressClassResource = {
          name    = "public"
          default = true
          # enabled = true
        }

        config = {
          enable-opentracing              = "false"
          opentracing-trust-incoming-span = "true"
          jaeger-collector-host           = "otel-trace-collector.observability"
          opentracing-operation-name      = "public"
        }

        extraArgs = {
          default-ssl-certificate = "api/ingress-server-cert"
        }
      }
    })
  ]
}
