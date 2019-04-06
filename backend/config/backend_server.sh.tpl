#!/usr/bin/env bash

sudo apt-get install git -y
cd /opt
sudo git clone "${git_repo}" test
sudo systemctl restart python-server