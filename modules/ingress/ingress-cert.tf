resource "tls_private_key" "ingress_pk" {
  count       = 1
  algorithm   = "ECDSA"
  ecdsa_curve = "P256"
}

resource "tls_cert_request" "ingress_cert_req" {
  count           = 1
  private_key_pem = tls_private_key.ingress_pk[0].private_key_pem

  subject {
    country      = "UT"
    province     = "UT"
    locality     = "UT"
    organization = "nextjs-grpc"
  }

  dns_names = [
    "${var.sld}.${var.tld}",
    "grafana.${var.sld}.${var.tld}",
    "prometheus.${var.sld}.${var.tld}",
    "jaeger.${var.sld}.${var.tld}",
    "kubernetes-dashboard.${var.sld}.${var.tld}",
  ]
}

resource "tls_locally_signed_cert" "ingress_cert" {
  count              = 1
  cert_request_pem   = tls_cert_request.ingress_cert_req[0].cert_request_pem
  ca_private_key_pem = local.certificate_authority.key
  ca_cert_pem        = local.certificate_authority.cert

  validity_period_hours = 12

  allowed_uses = [
    "server_auth",
  ]
}

resource "kubernetes_secret" "ingress_server_cert" {
  count = 1

  metadata {
    name      = "ingress-server-cert"
    namespace = kubernetes_namespace.ingress[0].metadata[0].name
  }

  type = "kubernetes.io/tls"

  data = {
    "ca.crt"  = local.certificate_authority.cert
    "tls.key" = tls_private_key.ingress_pk[0].private_key_pem
    "tls.crt" = join("", [
      tls_locally_signed_cert.ingress_cert[0].cert_pem,
      local.certificate_authority.cert
    ])
  }
}
