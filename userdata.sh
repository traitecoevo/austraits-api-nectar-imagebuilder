#!/bin/bash -eux

# DPkg::Lock::Timeout should work around apt lock race condition at startup ...
# (see https://blog.sinjakli.co.uk/2021/10/25/waiting-for-apt-locks-without-the-hacky-bash-scripts/)
apt_opts="-o DPkg::Lock::Timeout=60 -qq"
# ... but this hack still seems necessary
sleep 10

export DEBIAN_FRONTEND=noninteractive
echo "debconf debconf/frontend select Noninteractive" | sudo debconf-set-selections

sudo apt-get update $apt_opts
sudo apt-get install $apt_opts apt-utils software-properties-common

sudo apt-get dist-upgrade $apt_opts

# This is to get a newer version (4.x) of r-base than in Ubuntu repos
curl --silent https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc | sudo tee -a /etc/apt/trusted.gpg.d/cran_ubuntu_key.asc > /dev/null
sudo add-apt-repository "deb https://cloud.r-project.org/bin/linux/ubuntu $(lsb_release -cs)-cran40/"
# This is to get newer versions of r-cran-* packages than in Ubuntu repos
sudo add-apt-repository -y ppa:c2d4u.team/c2d4u4.0+
# For Filebeat
curl --silent https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
sudo add-apt-repository "deb https://artifacts.elastic.co/packages/8.x/apt stable main"

sudo apt-get update $apt_opts
sudo apt-get install $apt_opts --no-install-recommends `cat /tmp/packages.txt`
rm /tmp/packages.txt

sudo apt-get remove $apt_opts unattended-upgrades
sudo apt-get clean $apt_opts
