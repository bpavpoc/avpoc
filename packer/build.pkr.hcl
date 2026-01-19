variable "image_name" {
  default = "hello-node-app"
}

# The null builder is built-in; no plugin block needed
source "null" "node_app" {
  communicator = "none"
}

build {
  sources = ["source.null.node_app"]

  # Build the image using the static Dockerfile in the root
  provisioner "shell-local" {
    inline = [
      "nerdctl build -t ${var.image_name}:latest -f Dockerfile ."
    ]
  }

  # Export the image using nerdctl save
  post-processor "shell-local" {
    inline = [
      "echo '==> Exporting image from containerd...'",
      "nerdctl save ${var.image_name}:latest > ${var.image_name}.tar"
    ]
  }
}