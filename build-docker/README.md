# 🚀 Yocto Docker Builder - Raspberry Pi KAS

Welcome to the **Yocto Docker Builder**, a containerized environment specifically optimized for building Raspberry Pi images using KAS and Yocto. This project provides a **reliable, reproducible, and isolated** build environment. 🎯

## 🎯 Key Features

- **Containerized KAS build environment** 🐳
- **Raspberry Pi-specific configurations**
- **KAS yaml-based build management**
- **Optimized for Yocto Kirkstone**
- **Automated dependency management**
- **Multi-core build optimization**
- **Smart caching system**

## 📋 Requirements

- Docker Engine 20.10+
- Docker Compose v2.0+
- 100GB+ free disk space
- 16GB+ RAM recommended
- Unix-based OS (Linux/macOS)

## 🚀 Getting Started

### 1. Initial Setup

```bash
# Clone the repository
git clone git@github.com:soc-pi/raspberry-pi-kas.git
cd raspberry-pi-kas/build-docker

# Build the environment
make build
```

### 2. Build Management

```bash
# Start the build container
make run

# Access the container
make exec

# Build using KAS
kas build kas-project.yml
```

## 🔧 Build Configuration

### KAS Configuration File

```yaml
header:
  version: 8
machine: raspberrypi4-64
distro: poky
target: core-image-minimal
```

## 📊 Project Structure

```
raspberry-pi-kas/
├── build-docker/          # Docker build environment
│   ├── Dockerfile        # Container definition
│   ├── docker-compose.yml
│   └── Makefile         # Build automation
├── kas/                  # KAS configuration files
│   └── kas-project.yml  # Main build config
└── layers/              # Custom Yocto layers
```

## 🛠️ Makefile Commands

| Command      | Description                  |
| ------------ | ---------------------------- |
| `make build` | Build the Docker environment |
| `make run`   | Start the container          |
| `make exec`  | Access the container shell   |
| `make clean` | Clean build artifacts        |
| `make logs`  | View build logs              |

## 🔄 Build Process

1. **Environment Setup**

   - Container initialization
   - KAS configuration validation
   - Layer synchronization

2. **Build Execution**

   - Dependency resolution
   - Source fetching
   - Package compilation
   - Image generation

3. **Output Generation**
   - SD card image creation
   - Package manifests
   - Build logs

## 💡 Tips & Tricks

- Use `DL_DIR` and `SSTATE_DIR` for faster rebuilds
- Enable parallel build with `BB_NUMBER_THREADS`
- Monitor resource usage with `docker stats`
- Use `ccache` for faster compilation

## 🔍 Troubleshooting

### Common Issues

1. **Build Space Issues**

   ```bash
   make clean
   docker system prune
   ```

2. **Memory Problems**
   - Increase Docker memory limit
   - Reduce parallel jobs

## 📚 Resources

- [Yocto Project Documentation](https://docs.yoctoproject.org/)
- [KAS Documentation](https://kas.readthedocs.io/)
- [Raspberry Pi Documentation](https://www.raspberrypi.org/documentation/)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Commit changes
4. Submit a pull request

## 📝 License

MIT License - Feel free to use and modify! 🚀

## 📮 Support

- Create an issue for bugs
- Join our Discord community
- Check the Wiki for more details
