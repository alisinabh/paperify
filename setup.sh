#!/bin/bash

echo "What package manager do you use?"
echo "APT"
echo "PACMAN"

read packageman

if [ "$packageman" = "apt" ]; then
  sudo apt update
  sudo apt install -y imagemagick
  sudo apt install -y libzbar-dev
  sudo apt install -y qrencode
elif [ "$packageman" = "pacman" ]; then
  sudo pacman -S imagemagick libzbar-dev qrencode
elif [ "$packageman" = "yum" ]; then
  yum install -y imagemagick
  yum install -y libzbar-dev
  yum install -y qrencode
else
  echo "Invalid package manager selected."
fi
