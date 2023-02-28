#!/bin/bash

echo "What package manager do you use?"
echo "APT"
echo "PACMAN"

read packageman

if [ "$packageman" = "APT" ]; then
  sudo apt update
  sudo apt install imagemagick
  sudo apt install libzbar-dev
  sudo apt install qrencode
elif [ "$packageman" = "PACMAN" ]; then
  sudo pacman -S imagemagick libzbar-dev qrencode
else
  echo "Invalid package manager selected."
fi
