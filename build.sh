#!/bin/bash

set -e  # Exit on any error

echo "Starting Flutter build process..."

# Install Flutter SDK
echo "Installing Flutter SDK..."
cd /tmp
curl -fsSL https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.24.5-stable.tar.xz | tar -xJ
export PATH="/tmp/flutter/bin:$PATH"

# Verify Flutter installation
echo "Verifying Flutter installation..."
flutter --version

# Navigate to frontend directory
cd /vercel/path0/frontend

# Install dependencies
echo "Installing Flutter dependencies..."
flutter pub get

# Build Flutter web app
echo "Building Flutter web app..."
flutter build web --release --web-renderer html

echo "Build completed successfully!"
