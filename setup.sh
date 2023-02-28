#!/bin/bash

echo "What package manager do you use?"
echo "APT"
echo "PACMAN"

read packageman

if [ "$packageman" = "APT" ]; then
  sudo apt update
  sudo apt install -y imagemagick
  sudo apt install -y libzbar-dev
  sudo apt install -y qrencode
elif [ "$packageman" = "PACMAN" ]; then
  sudo pacman -S imagemagick libzbar-dev qrencode
else
  echo "Invalid package manager selected."
fi
