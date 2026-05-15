#!/bin/bash

# Install Flutter in a local directory
if [ ! -d "flutter_sdk" ]; then
  echo "Cloning Flutter..."
  git clone https://github.com/flutter/flutter.git -b stable flutter_sdk
fi

# Add Flutter to PATH
export PATH="$PATH:$(pwd)/flutter_sdk/bin"

echo "Checking Flutter version..."
flutter --version

# Move to frontend directory
cd flutter_frontend

echo "Running flutter pub get..."
flutter pub get

# Building Flutter Web
flutter build web --release

echo "Build finished successfully."
