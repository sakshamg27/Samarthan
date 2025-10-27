#!/bin/bash

set -e  # Exit on any error

echo "Starting Flutter build process..."

# Install Flutter SDK using git clone (more reliable for Vercel)
echo "Installing Flutter SDK..."
cd /tmp
git clone https://github.com/flutter/flutter.git -b stable flutter
export PATH="/tmp/flutter/bin:$PATH"

# Verify Flutter installation
echo "Verifying Flutter installation..."
flutter --version
flutter doctor

# Navigate to frontend directory
cd /vercel/path0/frontend

# Clean any existing build
echo "Cleaning previous builds..."
flutter clean

# Install dependencies
echo "Installing Flutter dependencies..."
flutter pub get

# Build Flutter web app
echo "Building Flutter web app..."
flutter build web --release --web-renderer html

echo "Build completed successfully!"
