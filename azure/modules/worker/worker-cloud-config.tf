resource "gzip_me" "ca" {
  input = "${ var.ca }"
}

resource "gzip_me" "worker" {
  input = "${ var.worker }"
}

resource "gzip_me" "worker_key" {
  input = "${ var.worker_key }"
}

resource "gzip_me" "kubeconfig" {
  input = "${ data.template_file.kubeconfig.rendered }"
}

resource "gzip_me" "kube_proxy" {
  input = "${ data.template_file.kube-proxy.rendered }"
}

data "template_file" "worker_cloud_config" {
  template = "${ file( "${ path.module }/worker-cloud-config.yml" )}"

  vars {
    cluster_domain = "${ var.cluster_domain }"
    dns_service_ip = "${ var.dns_service_ip }"
    kubelet_image_url = "${ var.kubelet_image_url }"
    kubelet_image_tag = "${ var.kubelet_image_tag }"
    internal_tld = "${ var.internal_tld }"
    location = "${ var.location }"
    azure_cloud = "${ var.azure_cloud }"
    master_node = "${ var.name }-master1.${ var.dns_suffix }"
    ca = "${ gzip_me.ca.output }"
    worker = "${ gzip_me.worker.output }"
    worker_key = "${ gzip_me.worker_key.output }"
    kube_config = "${ gzip_me.kubeconfig.output }"
    kube_proxy = "${ gzip_me.kube_proxy.output }"
  }
}

data "template_file" "kube-proxy" {
  template = "${ file( "${ path.module }/kube-proxy.yml" )}"

  vars {
    master_node = "${ var.name }-master1.${ var.dns_suffix }"
  }
}

data "template_file" "kubeconfig" {
  template = "${ file( "${ path.module }/kubeconfig" )}"

  vars {
    ca = "${ base64encode( var.ca ) }"
    token = "${ var.kube_proxy_token }"
  }
}

