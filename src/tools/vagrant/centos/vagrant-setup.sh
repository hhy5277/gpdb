#!/bin/bash

set -x

# packages needed to build and run GPDB
dependencies=(
  ed
  readline-devel
  zlib-devel
  curl-devel
  bzip2-devel
  python-devel
  apr-devel
  libevent-devel
  openssl-libs openssl-devel
  libyaml libyaml-devel
  epel-release
  htop
  ccache
  libffi-devel
  libxml2-devel
  perl-Env perl-ExtUtils-Embed
  cmake3
  net-tools # gives us netstat
  wget # to fetch get-pip.py
  vim mc psmisc # miscellaneous
)

sudo yum -y groupinstall 'Development tools'
sudo yum -y install "${dependencies[@]}"

# so we can call cmake
sudo ln -s /usr/bin/cmake{3,}

# python/pip
wget https://bootstrap.pypa.io/get-pip.py
sudo python get-pip.py
sudo pip install psutil lockfile paramiko setuptools
rm get-pip.py

sudo chown -R vagrant:vagrant /usr/local
