#!/bin/bash

detect_os() {
  if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    echo "linux"
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    echo "macos"
  else
    echo "unknown"
  fi
}

detect_package_manager() {
  local os=$1
  if [ "$os" = "linux" ]; then
    if command -v apt &> /dev/null; then
      echo "apt"
    elif command -v pacman &> /dev/null; then
      echo "pacman"
    elif command -v yum &> /dev/null; then
      echo "yum"
    else
      echo "unknown"
    fi
  elif [ "$os" = "macos" ]; then
    if command -v brew &> /dev/null; then
      echo "brew"
    else
      echo "unknown"
    fi
  else
    echo "unknown"
  fi
}

run_sudo_command() {
  if command -v sudo &> /dev/null; then
    sudo "$@"
  else
    "$@"
  fi
}

os=$(detect_os)
packageman=$(detect_package_manager "$os")

echo "OS: $os Package Manager: $packageman"

if [ "$packageman" = "apt" ]; then
  run_sudo_command apt update
  run_sudo_command apt install -y imagemagick libzbar-dev qrencode zbar-tools
elif [ "$packageman" = "pacman" ]; then
  run_sudo_command pacman -Syu imagemagick zbar qrencode
elif [ "$packageman" = "yum" ]; then
  run_sudo_command yum install -y imagemagick zbar-devel qrencode
elif [ "$packageman" = "brew" ]; then
  brew install imagemagick zbar qrencode
else
  echo "Unable to detect a supported package manager."
fi
