# Use Ubuntu image to build Flutter web app
FROM ubuntu:focal

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Bangkok

# Install dependencies for Flutter and Python HTTP server
RUN apt-get update && \
    apt-get install -y curl git unzip xz-utils python3 && \
    rm -rf /var/lib/apt/lists/*

# Install Flutter SDK
RUN git clone https://github.com/flutter/flutter.git -b stable /flutter
ENV PATH="/flutter/bin:${PATH}"

# Build Flutter web app
WORKDIR /app
COPY pubspec.yaml ./
RUN flutter pub get
COPY . .
RUN flutter build web --release

# Serve the built app using Python HTTP server
EXPOSE 8080
CMD ["python3", "-m", "http.server", "8080", "--directory", "build/web"]
