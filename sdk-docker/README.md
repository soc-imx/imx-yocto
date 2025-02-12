# 🚀 Yocto Docker Builder - raspberry pi

Welcome to the **Yocto Docker Builder**, a streamlined, containerized environment for building Yocto projects using Docker. This project provides a **lightning-fast, reproducible, and isolated** setup, ensuring a **hassle-free** experience for Yocto builds. Say goodbye to dependency hell and inconsistent environments! 🚀🔥

## 🏗️ Features

- **Fully containerized build environment** 🐳
- **Minimal host dependencies** (Just Docker & Docker Compose!)
- **Reproducible builds** across machines and environments
- **Automatic volume management** for persistent storage
- **Preconfigured for Yocto builds** (but flexible for other needs)
- **Multi-architecture support** (x86_64, ARM, etc.)
- **Optimized caching** to reduce build times

## 📦 Prerequisites

Ensure you have the following installed on your system:

- [Docker](https://docs.docker.com/get-docker/)
- [Docker Compose](https://docs.docker.com/compose/install/)

## 🚀 Quick Start

1. Clone this repository:

   ```bash
   git clone git@github.com:soc-pi/docker-pi.git
   cd docker-pi
   ```

2. Build the Docker image:

   ```bash
   docker-compose build
   ```

3. Run the container:

   ```bash
   docker-compose up -d
   ```

4. Enter the build environment:

   ```bash
   docker exec -it yocto-builder bash
   ```

5. Start your Yocto build inside the container:
   ```bash
   source /build/env-setup.sh && bitbake <your-target>
   ```

## 🛠️ Configuration

### Dockerfile

- **Based on Ubuntu/Debian** for maximum compatibility
- **Preinstalled build dependencies** to avoid long setup times
- **User permissions handled** to avoid root access issues

### `docker-compose.yml`

- **Mounts local directories** for persistent data storage
- **Customizable environment variables** for project-specific needs

Modify `docker-compose.override.yml` to tweak the setup according to your needs.

## 📂 Folder Structure

```
.
├── Dockerfile             # Defines the build environment
├── docker-compose.yml     # Defines the service
├── volumes/               # Persistent storage for builds
├── scripts/               # Custom helper scripts
└── README.md              # You are here 🚀
```

## 🚀 Advanced Usage

### Clean up old containers

```bash
docker-compose down --volumes --remove-orphans
```

### Rebuild the environment

```bash
docker-compose build --no-cache
```

### Stop and remove the container

```bash
docker-compose down
```

## 🔄 Updating Docker Compose

Remove the current Docker Compose:

```
sudo rm /usr/local/bin/docker-compose
```

Install the latest version of Docker Compose:

```
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

Verify the installation:

```
docker-compose --version
```

## 🔥 Why Use This?

- **No more broken dependencies!**
- **Consistent, repeatable builds across teams.**
- **Easy integration with CI/CD pipelines.**
- **Lightweight and efficient compared to VM-based setups.**

## 🤝 Contributing

PRs are welcome! Open an issue if you find a bug or have a feature request.

## 📜 License

MIT - Go wild! 🚀
