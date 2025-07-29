#!/bin/bash

install_neovim_latest() {
    echo -e "\033[36mInstalling neovim.....\033[0m"
    sleep 2
    curl -sL https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz | sudo tar -xzf - --strip-components=1 --overwrite -C /usr
}

setup_debian() {
    if [ "$VERSION_ID" -eq "13" ]; then VERSION_ID="Unstable"; fi
    apt update
    apt install sudo gpg -y
    echo -e "\033[36mInstalling fish shell.....\033[0m"
    sleep 2
    echo "deb http://download.opensuse.org/repositories/shells:/fish:/release:/4/Debian_$VERSION_ID/ /" | sudo tee /etc/apt/sources.list.d/shells:fish:release:4.list
    curl -fsSL https://download.opensuse.org/repositories/shells:fish:release:4/Debian_12/Release.key | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/shells_fish_release_4.gpg > /dev/null
    sudo apt update
    sudo apt install fish -y
    install_neovim_latest
    echo "\033[31mDebian initiation completed.....\033[0m"
}

setup_ubuntu() {
    apt update
    apt install sudo -y
    echo -e "\033[36mInstalling fish shell.....\033[0m"
    sleep 2
    sudo add-apt-repository ppa:fish-shell/release-4
    sudo apt update
    sudo apt install fish -y
    install_neovim_latest
    echo -e "\033[31mUbuntu initiation completed.....\033[0m"
}

setup_docker() {
    curl -fsSL https://get.docker.com | sh
    echo -e "\033[32mDocker Installed.....\033[0m"
    if [[ "$USER_FLAG" -eq 1 ]]; then usermod -aG docker $USERNAME; fi
    echo -e "\033[31mDocker Installed .....\033[0m"
}

setup_user() {
    echo "Enter Username"
    read USERNAME
    if [[ -z "$USERNAME" ]]; then echo "\033[31mUSERNAME not set.....\033[0m"; return; fi
    sugroup=$(getent group | grep -E "(wheel|sudo)" | head -n1 | cut -d: -f1)
    case $sugroup in
        sudo)
            useradd -m -u 1000 -s /usr/bin/fish $USERNAME -G sudo
            ;;
        wheel)
            useradd -m -u 1000 -s /usr/bin/fish $USERNAME -G wheel
            ;;
        *)
            echo "sudo is not ready"
            ;;
    esac
    if [[ -d /root/.ssh ]]; then 
        cp -r /root/.ssh /home/$USERNAME/.ssh
        chown -R $USERNAME:$USERNAME /home/$USERNAME/.ssh
    fi
    echo -e "\033[33mUser Created, excecuted passwd $USERNAME to setup password.....\033[0m"
    USER_FLAG=1
}

setup_dnf_distros() {
        dnf update
        dnf install --skip-broken sudo gpg unzip -y
        sudo dnf install fish neovim -y
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
        setup_dnf_distros
    ;;

    arch)
        pacman -Sy --needed --noconfirm sudo fish neovim
    ;;

    *) echo "This is an unknown distribution."
    ;;
    
    esac

echo -e "\033[33mSetup User? (y/n).....\033[0m" 
read choice
case $choice in
    y|Y|yes|YES)
        setup_user
    ;;
    n|N|no|NO) echo "Skipped..."
    ;;
    *) echo "Invalid input"
    ;;
esac

echo -e "\033[33mSetup Docker? (y/n).....\033[0m" 
read choice
case $choice in
    y|Y|yes|YES)
        setup_docker
    ;;
    n|N|no|NO) echo "Skipped..."
    ;;
    *) echo "Invalid input"
    ;;
esac