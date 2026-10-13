#!/usr/bin/env bash
set -euo pipefail

# Generate the Xcode project using XcodeGen
if ! command -v xcodegen >/dev/null 2>&1; then
  echo "xcodegen not found. Attempting to install via Homebrew..."
  brew update
  brew install xcodegen
fi

echo "Generating Xcode project from project.yml..."
xcodegen generate --spec project.yml

echo "Project generated: $(pwd)/HealthCheckApp.xcodeproj"
