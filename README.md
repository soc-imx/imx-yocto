# 🚀 Raspberry Pi KAS Build System

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![KAS](https://img.shields.io/badge/KAS-compatible-green.svg)](https://kas.readthedocs.io/)
[![Raspberry Pi](https://img.shields.io/badge/Raspberry%20Pi-supported-red.svg)](https://www.raspberrypi.org/)

A comprehensive build system for generating custom Raspberry Pi images using the KAS (Kas Assembly System) build tool.

## 📋 Table of Contents

- [Features](#features)
- [Prerequisites](#prerequisites)
- [Supported Boards](#supported-boards)
- [Quick Start](#quick-start)
- [Detailed Usage](#detailed-usage)
- [SDK Generation](#sdk-generation)
- [Directory Structure](#directory-structure)
- [Advanced Configuration](#advanced-configuration)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)

## ✨ Features

- Multi-board support for various Raspberry Pi models
- Automated image building with logging
- SDK generation capabilities
- Parallel build support
- Comprehensive logging system
- Docker/Podman container support
- Custom configuration options
- Interactive shell access

## 🔧 Prerequisites

- Linux-based operating system
- KAS build tool (`pip install kas`)
- Docker or Podman
- Git
- Make
- Python 3.6+
- 50GB+ free disk space
- 16GB+ RAM recommended

## 🎯 Supported Boards

- Raspberry Pi Zero 2 W (64-bit)
- Raspberry Pi 2
- Raspberry Pi 3
- Raspberry Pi 4
- Raspberry Pi 5
- Raspberry Pi CM3/CM4
- And more!

## 🚀 Quick Start

```bash
# Clone the repository
git clone https://github.com/yourusername/raspberry-pi-kas.git
cd raspberry-pi-kas

# Build for Raspberry Pi 4
make build-raspberrypi4

# Generate SDK for Raspberry Pi 4
make sdk-raspberrypi4

# Build all supported boards
make build-all
```

## 📖 Detailed Usage

### Basic Commands

```bash
# Show help
make help

# Show system information
make info

# Clean build artifacts
make clean

# Open interactive shell
make shell-raspberrypi4
```

### Build Options

```bash
# Build with custom options
make build-raspberrypi4 KAS_OPTS="-d -v"

# Generate SDK with options
make sdk-raspberrypi4 SDK_OPTS="--update"
```

## 🛠 SDK Generation

Generate SDKs for development:

```bash
# Generate SDK for specific board
make sdk-raspberrypi4

# Generate all SDKs
make sdk-all

# Access SDK shell
make sdk-shell-raspberrypi4
```

## 📁 Directory Structure

```
raspberry-pi-kas/
├── Makefile          # Main build system
├── kas/              # KAS configuration files
├── logs/             # Build logs
├── sdk/              # Generated SDKs
├── images/           # Output images
└── build/            # Temporary build files
```

## ⚙️ Advanced Configuration

### Custom KAS Configuration

Create custom configurations in `kas/`:

```yaml
header:
  version: 8
  includes:
    - base.yaml
machine: raspberrypi4
target: core-image-minimal
```

### Environment Variables

- `KAS_OPTS`: Additional KAS options
- `SDK_OPTS`: SDK generation options
- `IMAGE_OPTS`: Image build options

## 🔍 Troubleshooting

### Common Issues

1. **Build Failures**

   ```bash
   make debug  # Show system information
   cat logs/raspberrypi4/build-*.log  # Check build logs
   ```

2. **Space Issues**

   ```bash
   make clean  # Clean build artifacts
   df -h .     # Check available space
   ```

3. **Memory Issues**
   ```bash
   free -h     # Check available memory
   ```

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- KAS Project Team
- Raspberry Pi Foundation
- Yocto Project
- Open Embedded Community

## 📞 Support

- Create an issue on GitHub
- Join our Discord community
- Check the [Wiki](../../wiki) for more information

---

Built with ❤️ for the Raspberry Pi Community
