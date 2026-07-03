#!/bin/bash
export DEBIAN_FRONTEND=noninteractive
echo "tzdata tzdata/Areas select Asia" | debconf-set-selections
echo "tzdata tzdata/Zones/Asia select Kolkata" | debconf-set-selections

apt update; apt upgrade -y

apt install -y python3 python3-pip

cd /root/setup-linux

python3 -m venv .venv
source .venv/bin/activate
pip install -r requirments.txt
python3 setup.py


