resource "helm_release" "ingress" {
  count      = local.deployment_configs.ingress.count
  name       = "ingress"
  chart      = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  version    = "4.2.5"
  namespace  = kubernetes_namespace.ingress[0].metadata[0].name

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
        }

        config = {
          enable-opentracing              = "false"
          opentracing-trust-incoming-span = "true"
          jaeger-collector-host           = "otel-trace-collector.observability"
          opentracing-operation-name      = "public"
        }

        extraArgs = {
          default-ssl-certificate = join("/", [
            kubernetes_namespace.ingress[0].metadata[0].name,
            kubernetes_secret.ingress_server_cert[0].metadata[0].name
          ])
        }
      }
    })
  ]
}
