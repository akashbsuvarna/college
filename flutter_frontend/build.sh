#!/bin/bash

# Install Flutter in a local directory
if [ ! -d "../flutter" ]; then
  echo "Cloning Flutter..."
  git clone https://github.com/flutter/flutter.git -b stable ../flutter
fi

# Add Flutter to PATH
export PATH="$PATH:$(pwd)/../flutter/bin"

echo "Checking Flutter version..."
flutter --version

echo "Running flutter pub get..."
flutter pub get

# Building Flutter Web
flutter build web --release

echo "Build finished successfully."
