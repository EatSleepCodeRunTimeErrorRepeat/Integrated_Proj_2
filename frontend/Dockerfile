FROM ubuntu:focal

# 1. Prevent tzdata from prompting for geographic area
#    and timezone during build
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Bangkok

# 2. Install system dependencies + tzdata non-interactively
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      tzdata \
      curl git unzip xz-utils libglu1-mesa clang cmake ninja-build \
      pkg-config libgtk-3-dev openjdk-17-jdk python3 && \
    rm -rf /var/lib/apt/lists/*

# 3. Clone Flutter SDK
RUN git clone https://github.com/flutter/flutter.git -b stable /flutter
ENV PATH="/flutter/bin:${PATH}"

# 4. Build your Flutter app
WORKDIR /app
COPY pubspec.yaml ./
RUN flutter pub get
COPY . .
RUN flutter build web --release

# 5. Serve the build
EXPOSE 8080
CMD ["python3", "-m", "http.server", "8080", "--directory", "build/web"]