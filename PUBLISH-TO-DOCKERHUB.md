# Publishing to Docker Hub - thornlcsw

## 🚀 Quick Publish Guide

This guide helps you publish your customized Claude Code image to Docker Hub under your username `thornlcsw`.

### Prerequisites
- Docker Hub account: `thornlcsw`
- Docker CLI installed and logged in

### 1. **Login to Docker Hub**
```bash
docker login
# Enter your thornlcsw credentials
```

### 2. **Build the Image**
```bash
# Build with your username tag
docker build -f Dockerfile.volume-mount -t thornlcsw/claude-code-customized:latest .

# Also tag with version
docker tag thornlcsw/claude-code-customized:latest thornlcsw/claude-code-customized:v1.2
```

### 3. **Test Locally**
```bash
# Test the image before pushing
docker run --rm -v ./claude-binary:/claude-binaries thornlcsw/claude-code-customized:latest /bin/bash -c "echo 'Testing image...' && sudo whoami"
```

### 4. **Push to Docker Hub**
```bash
# Push latest version
docker push thornlcsw/claude-code-customized:latest

# Push versioned tag
docker push thornlcsw/claude-code-customized:v1.2
```

### 5. **Verify on Docker Hub**
- Visit: https://hub.docker.com/r/thornlcsw/claude-code-customized
- Check that the image is visible and tags are correct

### 6. **Test Public Pull**
```bash
# Test pulling from a different machine
docker pull thornlcsw/claude-code-customized:latest
docker run --rm thornlcsw/claude-code-customized:latest echo "Success!"
```

## 📋 Docker Hub Description

Use the content from `DOCKERHUB-README.md` as your Docker Hub repository description. This includes:

- ✅ Professional overview with badges
- ✅ Quick start instructions
- ✅ Feature highlights
- ✅ Usage examples
- ✅ Configuration options
- ✅ Security information
- ✅ Support links

## 🏷️ Recommended Tags

```bash
# Version tags
docker tag thornlcsw/claude-code-customized:latest thornlcsw/claude-code-customized:v1.0
docker tag thornlcsw/claude-code-customized:latest thornlcsw/claude-code-customized:v1.1
docker tag thornlcsw/claude-code-customized:latest thornlcsw/claude-code-customized:v1.2

# Feature-specific tags
docker tag thornlcsw/claude-code-customized:latest thornlcsw/claude-code-customized:sudo-escalation
docker tag thornlcsw/claude-code-customized:latest thornlcsw/claude-code-customized:system-prompts

# Push all tags
docker push thornlcsw/claude-code-customized --all-tags
```

## 📊 Expected Image Information

- **Repository**: `thornlcsw/claude-code-customized`
- **Size**: ~880MB (optimized Ubuntu 22.04 base)
- **Architecture**: linux/amd64, linux/arm64
- **Base Image**: ubuntu:22.04
- **Last Updated**: [Current date]

## 🔗 Links After Publishing

Once published, your image will be available at:

- **Docker Hub**: https://hub.docker.com/r/thornlcsw/claude-code-customized
- **Pull Command**: `docker pull thornlcsw/claude-code-customized:latest`
- **Docker Compose**: Already configured in `docker-compose.yml`

## 📝 Post-Publishing Checklist

- [ ] Image builds successfully
- [ ] All tags pushed correctly
- [ ] Docker Hub description updated
- [ ] README.md visible on Docker Hub
- [ ] Pull test from different machine works
- [ ] Documentation links are correct
- [ ] Example commands work as expected

## 🚀 Automation Script

For future updates, you can use this script:

```bash
#!/bin/bash
# publish.sh - Automated publishing script

set -e

VERSION=${1:-latest}
USERNAME="thornlcsw"
IMAGE_NAME="claude-code-customized"

echo "🏗️  Building image for $USERNAME/$IMAGE_NAME:$VERSION"
docker build -f Dockerfile.volume-mount -t $USERNAME/$IMAGE_NAME:$VERSION .

echo "🧪 Testing image locally"
docker run --rm $USERNAME/$IMAGE_NAME:$VERSION echo "Local test successful!"

echo "📤 Pushing to Docker Hub"
docker push $USERNAME/$IMAGE_NAME:$VERSION

echo "✅ Successfully published $USERNAME/$IMAGE_NAME:$VERSION"
echo "🔗 Available at: https://hub.docker.com/r/$USERNAME/$IMAGE_NAME"
```

Usage:
```bash
chmod +x publish.sh
./publish.sh          # Push as latest
./publish.sh v1.3     # Push as versioned tag
```

---

**Ready to publish!** Your image is fully prepared for public distribution under `thornlcsw/claude-code-customized`.