#!/bin/bash

echo "What package manager do you use?"
echo "Choose one of the following:"
echo "apt"
echo "pacman"
echo "yum"

read packageman

if [ "$packageman" = "apt" ]; then
  sudo apt update
  sudo apt install -y imagemagick
  sudo apt install -y libzbar-dev
  sudo apt install -y qrencode
elif [ "$packageman" = "pacman" ]; then
  sudo pacman -S imagemagick libzbar-dev qrencode
elif [ "$packageman" = "yum" ]; then
  sudo yum install -y imagemagick
  sudo yum install -y libzbar-dev
  sudo yum install -y qrencode
else
  echo "Invalid package manager selected."
fi
