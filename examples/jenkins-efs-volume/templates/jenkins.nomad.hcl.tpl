job "${job_name}" {
  datacenters = [
%{ for dc in datacenters ~}
    "${dc}",
%{ endfor ~}
  ]
  type = "service"

  group "jenkins" {
    count = 1

    volume "jenkins_home" {
      type      = "csi"
      read_only = false
      source    = "${volume_name}"
    }

    task "jenkins" {
      driver = "docker"

      volume_mount {
        volume      = "${volume_name}"
        destination = "/var/jenkins_home"
        read_only   = false
      }

      config {
        image = "jenkins/jenkins:latest"

        port_map {
          http = 8080
          jnlp = 50000
        }
      }

      resources {
        cpu    = 500
        memory = 512
        network {
          port "http" {}
          port "jnlp" {}
        }
      }

      service {
        name = "jenkins"
        port = "http"

        check {
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }
  }
}