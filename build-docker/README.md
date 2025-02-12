# Raspberry Pi KAS Docker Build System

A streamlined Docker-based build system for Kubernetes at Scale (KAS) on Raspberry Pi.

## 📋 Features

- Automated Docker build environment
- Cross-platform compatibility
- Pre-configured Raspberry Pi toolchain
- Optimized for KAS (Kubernetes at Scale)

## 🚀 Quick Start

### Prerequisites

- Docker installed
- Git
- 20GB free disk space
- Internet connection

### Installation

```bash
# Clone the repository
git clone https://github.com/yourusername/raspberry-pi-kas.git

# Navigate to build directory
cd raspberry-pi-kas/build-docker

# Build the Docker image
docker build -t kas-builder .
```

## 🔧 Usage

### Basic Build

```bash
docker run -it --rm \
  -v $(pwd):/workspace \
  kas-builder build kas-project.yml
```

### Development Mode

```bash
docker run -it --rm \
  -v $(pwd):/workspace \
  --name kas-dev \
  kas-builder bash
```

## 📦 Build Configuration

The system supports various build configurations:

- Debug builds (`-v DEBUG=1`)
- Release builds (default)
- Custom configurations via environment variables

## 🛠 Customization

Modify `Dockerfile` or `kas-project.yml` for:

- Custom package selection
- Build optimizations
- Target architecture settings

## 🐛 Troubleshooting

Common issues and solutions:

1. **Build fails with memory error**

   - Increase Docker memory allocation
   - Clear Docker cache

2. **Network connectivity issues**
   - Check proxy settings
   - Verify network permissions

## 📝 Contributing

1. Fork the repository
2. Create your feature branch
3. Commit changes
4. Push to the branch
5. Create Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 👥 Maintainers

- Your Name (@githubhandle)

## 🙏 Acknowledgments

- Raspberry Pi Foundation
- KAS Project Contributors
- Docker Community
