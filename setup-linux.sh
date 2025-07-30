#!/bin/bash

install_neovim_latest() {
    echo -e "\033[36mInstalling neovim.....\033[0m"
    . /etc/os-release

    case $ID in
        debian|ubuntu)
        REQUIRED_PKG="curl"
        PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $REQUIRED_PKG|grep "install ok installed")
        echo Checking for $REQUIRED_PKG: $PKG_OK
        if [ "" = "$PKG_OK" ]; then
            echo "No $REQUIRED_PKG. Setting up $REQUIRED_PKG."
            apt install $REQUIRED_PKG -y
        fi
        curl -f https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz | sudo tar -xzvf - --strip-components=1 --overwrite -C /usr
        ;;

        fedora)
            dnf install neovim -y
        ;;

        arch)
            pacman -S --noconfirm --needed neovim
        ;;

        *) echo "This is an unknown distribution."
        ;;
    esac
            
}

install_fish_latest() {
    . /etc/os-release

    case $ID in
        debian)
            echo -e "\033[36mDebian \033[0m"
            REQUIRED_PKG="wget"
            PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $REQUIRED_PKG|grep "install ok installed")
            echo Checking for $REQUIRED_PKG: $PKG_OK
            if [ "" = "$PKG_OK" ]; then
                echo "No $REQUIRED_PKG. Setting up $REQUIRED_PKG."
                apt update
                apt install $REQUIRED_PKG -y
            fi
            if [ "$VERSION_ID" -eq "13" ]; then VERSION_ID="Unstable"; fi
            wget -qO fish.deb "https://download.opensuse.org/repositories/shells:/fish:/release:/4/Debian_$VERSION_ID/amd64/fish_4.0.2-2_amd64.deb"
            apt install $(pwd)/fish.deb -y
            rm -f fish.deb
        ;;

        ubuntu)
            echo -e "\033[36mUbuntu \033[0m"
            apt update
            echo -e "\033[36mInstalling fish shell.....\033[0m"
            add-apt-repository ppa:fish-shell/release-4
            apt update
            apt install fish -y
        ;;
        fedora)
            echo -e "\033[36mFedora \033[0m"
            dnf install fish -y
        ;;

        arch)
            echo -e "\033[36mArch 󰣇\033[0m"
            pacman -S --noconfirm --needed fish
        ;;

        *) echo " This is an unknown distribution ."
        ;;
    esac

}

setup_docker() {
    curl -fsSL https://get.docker.com | sh
    if [[ -n $USERNAME ]]; then 
        usermod -aG docker $USERNAME
        echo -e "\033[36m$USERNAME added to docker group\033[0m"
    fi
    echo -e "\033[36mDocker Installed .....\033[0m"
}

setup_user() {

    echo "Setting User..."
    
  
    . /etc/os-release

    case $ID in
        debian|ubuntu)
            echo -e "\033[36mDebian |Ubuntu \033[0m"
            REQUIRED_PKG="sudo"
            PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $REQUIRED_PKG|grep "install ok installed")
            echo Checking for $REQUIRED_PKG: $PKG_OK
            if [ "" = "$PKG_OK" ]; then
                echo "No $REQUIRED_PKG. Setting up $REQUIRED_PKG."  
                apt update
                apt install $REQUIRED_PKG -y
            fi
        ;;
        fedora)
            echo -e "\033[36mFedora \033[0m"
            dnf install sudo -y
        ;;

        arch)
            echo -e "\033[36mArch 󰣇\033[0m"
            pacman -S --noconfirm --needed sudo
        ;;

        *) echo " This is an unknown distribution ."
        ;;
    esac

    echo "Enter Username"
    read USERNAME
    if [[ -z "$USERNAME" ]]; then echo "\033[31mUSERNAME not set.....\033[0m"; return; fi
    sugroup=$(getent group | grep -E "(wheel|sudo)" | head -n1 | cut -d: -f1)
    case $sugroup in
        sudo)
            useradd -m -s /usr/bin/fish $USERNAME -G sudo
            ;;
        wheel)
            useradd -m -s /usr/bin/fish $USERNAME -G wheel
            ;;
        *)
            echo "sudo is not ready"
            ;;
    esac
    if [[ -d /root/.ssh ]]; then 
        cp -r /root/.ssh /home/$USERNAME/.ssh
        chown -R $USERNAME:$USERNAME /home/$USERNAME/.ssh
    fi
    echo -e "\033[36mUser Created. Ssh keys copied. Excecute passwd $USERNAME to setup password\033[0m"
}

setup_wrapper() {

    echo -e "\033[33mInstall fish (y/n)?\033[0m"
    read choice
    case $choice in 
        y|Y|yes|YES)
            install_fish_latest
            echo -e "\033[32mFish installed.....\033[0m"
            ;;
        n|N|no|NO) echo "Skipped fish..."
            ;;
        *) echo "Invalid input"
            ;;
    esac

   echo -e "\033[33mInstall neovim (y/n)?\033[0m"
    read choice
    case $choice in 
        y|Y|yes|YES)
            install_neovim_latest
            echo -e "\033[32mNeovim installed.....\033[0m"
            ;;
        n|N|no|NO) echo "Skipped neovim..."
            ;;
        *) echo "Invalid input"
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
}

main() {

    echo "Check root..."
    if [[ $UID -ne 0 ]]; then
        echo "Error: This script must be run as root" >&2
        exit 1
    fi 
    echo "Running as root "
    setup_wrapper
    echo -e "\033[32mCompleted\033[0m"
}

main "$@"