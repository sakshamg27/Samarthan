FROM ubuntu:20.04

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    xz-utils \
    zip \
    libglu1-mesa \
    python3 \
    && rm -rf /var/lib/apt/lists/*

# Install Flutter
RUN git clone https://github.com/flutter/flutter.git -b stable /flutter
ENV PATH="/flutter/bin:/flutter/bin/cache/dart-sdk/bin:${PATH}"

WORKDIR /app
COPY . .

# Install dependencies and build
RUN flutter pub get
RUN flutter build web --release

# Serve the built web app
EXPOSE 3000
CMD ["python3", "-m", "http.server", "3000", "--directory", "build/web"]
