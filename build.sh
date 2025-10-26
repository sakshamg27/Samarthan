#!/bin/bash

# Install Flutter 3.35.7
curl -fsSL https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.35.7-stable.tar.xz | tar -xJ -C /tmp
export PATH="/tmp/flutter/bin:$PATH"

# Install dependencies
cd frontend
flutter pub get

# Build Flutter web app
flutter build web --release

echo "Build completed successfully!"
