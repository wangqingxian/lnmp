#!/usr/bin/env bash

. /etc/os-release

. ~/.bashrc

. ~/.bash_profile

set -x

print_help_info(){
  echo "
  
Usage:

dockerd  Config Docker Daemon

  "
}

# check env
if [ -z $LNMP_PATH ];then
  echo export LNMP_PATH=~/lnmp >> ~/.bash_profile
  echo export LNMP_PATH=~/lnmp >> ~/.bashrc

  echo export "PATH=\$LNMP_PATH:\$LNMP_PATH/bin:\$LNMP_PATH/kubernetes:\$PATH" >> ~/.bash_profile
  echo export "PATH=\$LNMP_PATH:\$LNMP_PATH/bin:\$LNMP_PATH/kubernetes:\$PATH" >> ~/.bashrc
fi

if [ $NAME = Fedora ];then

  # install docker
  command -v docker
  if ! [ $? -eq 0 ];then
    sudo dnf -y install dnf-plugins-core

    sudo dnf config-manager \
    --add-repo \
    https://mirrors.ustc.edu.cn/docker-ce/linux/fedora/docker-ce.repo
    
    sudo dnf config-manager --set-enabled docker-ce-test

    sudo dnf install docker-ce

    sudo groupadd docker

    sudo usermod -aG docker $USER

    sudo systemctl enable docker

    sudo systemctl start docker
  fi
fi

# config docker

_docker_daemon(){
      echo '
{
  "registry-mirrors": [
  "https://registry.docker-cn.com"
  ],
  "debug": true,
  "dns": [
    "114.114.114.114",
    "8.8.8.8"
  ],
  "experimental": true
}' | sudo tee /etc/docker/daemon.json

  sudo systemctl restart docker
}

# config ssh

if ! [ -f ~/.ssh/id_rsa ];then
  ssh-keygen
fi

# rkt
__rkt(){
  if [ $NAME = Fedora ];then
    command -v rkt

    if ! [ $? -eq 0 ];then
      curl -L https://github.com/rkt/rkt/releases/download/v1.30.0/rkt-1.30.0-1.x86_64.rpm > /tmp/rkt.rpm

      sudo dnf install /tmp/rkt.rpm

      rkt version
    fi
fi
}

# install soft
if [ $NAME = Fedora ];then
  sudo dnf install -y tilix \
    kernel-devel elfutils-libelf-devel libefp-devel
fi

if [ "$1" = '--help' ];then print_help_info; fi
if [ "$1" = 'dockerd' ];then _docker_daemon; fi
if [ "$1" = 'rkt' ];then __rkt; fi
