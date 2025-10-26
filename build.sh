#!/bin/bash

# Install Flutter from GitHub (stable branch)
git clone https://github.com/flutter/flutter.git -b stable /tmp/flutter
export PATH="/tmp/flutter/bin:$PATH"

# Install dependencies
cd frontend
flutter pub get

# Build Flutter web app
flutter build web --release

echo "Build completed successfully!"
