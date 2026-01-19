# Node.js Hello-Name (Containerd + Packer)

A DevOps project demonstrating a containerized Node.js application built with **Packer**, run via **rootless nerdctl/containerd**, and automated with **GitHub Actions**.

## 🚀 Features
- **Rootless Execution**: No `sudo` required for container management.
- **Packer Built**: Immutable image creation without a standard Dockerfile.
- **Multi-Environment**: Logic to handle `development` and `production` modes.
- **Containerd Native**: Optimized for `nerdctl` instead of the full Docker daemon.

## 🧑‍💻 Usage

To manage the application lifecycle, use the provided `Makefile` commands. This project is designed to run in **rootless mode**; ensure your environment is configured for `nerdctl` without sudo.

- **Build & Export**: Run `make build` to trigger the **Packer** build process. This utilizes the `Dockerfile` to create an image within the `containerd` store and automatically exports it to `hello-node-app.tar`.

- **Automated Testing**: Execute `make test` to spin up a temporary container and verify that the `{entered_name}` logic, redirects, and environment-specific behaviors are functioning correctly.

- **Development Mode**: Use `make run-dev` to launch the app on **Port 3001** with `NODE_ENV=development`. This enables real-time debug logging in the container console.

- **Production Mode**: Use `make run-prod` to launch the app on **Port 8080** with `NODE_ENV=production`. This version uses the "User" default route and optimized logging.

- **Cleanup**: Run `make clean` to stop all active project containers and remove the exported tarball artifact.

## 🛠 Prerequisites & Installation

To run this project without `root` privileges, follow these official setup guides:

### 1. uidmap
* **Installation:** `sudo apt install uidmap`

### 2. nerdctl (Docker-compatible CLI for containerd)
A contiguous CLI for containerd that supports Docker-style commands and rootless mode.
* **Official Repo:** [github.com/containerd/nerdctl](https://github.com/containerd/nerdctl)
* **Source:** [Nerdctl Release Page](https://github.com/containerd/nerdctl/releases) (Download the `full` package with containerd, runc, rootleskit, CNI plugins, etc.).

#### Rootless Setup (Crucial)
To run containers without `sudo`, you must configure the user namespace.
* **Rootless Guide:** [nerdctl Rootless Documentation](https://github.com/containerd/nerdctl/blob/main/docs/rootless.md)
* **Quick Command:** `containerd-rootless-setuptool.sh install`

### 4. Packer
* **Installation:** [Install Packer](http://developer.hashicorp.com/packer/install)