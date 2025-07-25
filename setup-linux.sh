#!/bin/bash

install_neovim_latest() {
    echo -e "\033[36m Installing neovim \033[0m"
    sleep 2
    curl -sL https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz | sudo tar -xzf - --strip-components=1 --overwrite -C /usr
}

setup_debian() {
    if [ "$VERSION_ID" -eq "13" ]; then VERSION_ID="Unstable"; fi
    apt update
    apt install sudo curl gpg git unzip -y
    echo -e "\033[36m Installing fish shell \033[0m"
    sleep 2
    echo "deb http://download.opensuse.org/repositories/shells:/fish:/release:/4/Debian_$VERSION_ID/ /" | sudo tee /etc/apt/sources.list.d/shells:fish:release:4.list
    curl -fsSL https://download.opensuse.org/repositories/shells:fish:release:4/Debian_12/Release.key | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/shells_fish_release_4.gpg > /dev/null
    sudo apt update
    sudo apt install fish -y
    install_neovim_latest
    echo "Debian initiation completed"
}

setup_ubuntu() {
    apt update
    apt install sudo curl git unzip -y
    echo "Installing fish shell"
    sleep 2
    sudo add-apt-repository ppa:fish-shell/release-4
    sudo apt update
    sudo apt install fish -y
    install_neovim_latest
    echo "Ubuntu initiation completed"
}

. /etc/os-release

case $ID in
    debian)
        setup_debian
    ;;

    ubuntu)
        setup_ubuntu
    ;;

    fedora)
        dnf update
        dnf install sudo curl gpg git unzip -y
        sudo dnf install fish neovim -y
    ;;

    arch)
        pacman -S --needed sudo curl fish neovim git
    ;;

    *) echo "This is an unknown distribution."
    ;;
    esac