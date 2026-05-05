#!/bin/bash

install_neovim_latest() {
    echo -e "\033[36mInstalling Neovim .....\033[0m"
    . /etc/os-release

    case $ID in
        debian|ubuntu)
        REQUIRED_PKG="curl"
        PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $REQUIRED_PKG|grep "install ok installed")
        echo Checking for $REQUIRED_PKG: $PKG_OK
        if [ "" = "$PKG_OK" ]; then
            echo "No $REQUIRED_PKG. Setting up $REQUIRED_PKG."
            apt-get install $REQUIRED_PKG -y
        fi
        curl -f https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz | sudo tar -xzvf - --strip-components=1 --overwrite -C /usr
        ;;

        fedora)
            dnf install neovim -y
        ;;

        arch)
            pacman -Sy --noconfirm --needed neovim
        ;;

        *) echo "This is an unknown distribution."
        ;;
    esac
            
}

install_fish_latest() {
    . /etc/os-release

    echo -e "\033[36mInstalling Fish 󰈺.....\033[0m"
    case $ID in
        debian)
            echo -e "\033[36mDebian \033[0m"
            REQUIRED_PKG="wget curl gpg" # This breaks if any pkg is present
            PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $REQUIRED_PKG|grep "install ok installed")
            echo Checking for $REQUIRED_PKG: $PKG_OK
            if [ "" = "$PKG_OK" ]; then
                echo "No $REQUIRED_PKG. Setting up $REQUIRED_PKG."
                apt-get update
                apt-get install $REQUIRED_PKG -y
            fi
            if [ -z "$VERSION_ID" ]; then VERSION_ID="Unstable"; fi
            echo "deb http://download.opensuse.org/repositories/shells:/fish:/release:/4/Debian_$VERSION_ID/ /" | tee /etc/apt/sources.list.d/shells:fish:release:4.list
            curl -fsSL https://download.opensuse.org/repositories/shells:fish:release:4/Debian_"$VERSION_ID"/Release.key | gpg --dearmor | tee /etc/apt/trusted.gpg.d/shells_fish_release_4.gpg > /dev/null
            apt-get update
            apt-get install fish -y
            # rm -f fish.deb
        ;;

        ubuntu)
            echo -e "\033[36mUbuntu \033[0m"
            apt-get update
            echo -e "\033[36mInstalling fish shell.....\033[0m"
            add-apt-repository ppa:fish-shell/release-4
            apt-get update
            apt-get install fish -y
        ;;
        fedora)
            echo -e "\033[36mFedora \033[0m"
            dnf install fish -y
        ;;

        arch)
            echo -e "\033[36mArch 󰣇\033[0m"
            pacman -Sy --noconfirm --needed fish
        ;;

        *) echo " This is an unknown distribution ."
        return 2
        ;;
    esac

    usermod -s /usr/bin/fish "$USERNAME"
}

install_kitty() {
    . /etc/os-release

    echo -e "\033[36mInstalling Kitty .....\033[0m"
    case $ID in
        # debian)
        #     echo -e "\033[36mDebian \033[0m"
        #     REQUIRED_PKG="wget curl gpg" # This breaks if any pkg is present
        #     PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $REQUIRED_PKG|grep "install ok installed")
        #     echo Checking for $REQUIRED_PKG: $PKG_OK
        #     if [ "" = "$PKG_OK" ]; then
        #         echo "No $REQUIRED_PKG. Setting up $REQUIRED_PKG."
        #         apt-get update
        #         apt-get install $REQUIRED_PKG -y
        #     fi
        #     if [ -z "$VERSION_ID" ]; then VERSION_ID="Unstable"; fi
        #     echo "deb http://download.opensuse.org/repositories/shells:/fish:/release:/4/Debian_$VERSION_ID/ /" | tee /etc/apt/sources.list.d/shells:fish:release:4.list
        #     curl -fsSL https://download.opensuse.org/repositories/shells:fish:release:4/Debian_"$VERSION_ID"/Release.key | gpg --dearmor | tee /etc/apt/trusted.gpg.d/shells_fish_release_4.gpg > /dev/null
        #     apt-get update
        #     apt-get install fish -y
        #     # rm -f fish.deb
        # ;;

        # ubuntu)
        #     echo -e "\033[36mUbuntu \033[0m"
        #     apt-get update
        #     echo -e "\033[36mInstalling fish shell.....\033[0m"
        #     add-apt-repository ppa:fish-shell/release-4
        #     apt-get update
        #     apt-get install fish -y
        # ;;
        fedora)
            echo -e "\033[36mFedora \033[0m"
            dnf install kitty -y
        ;;

        arch)
            echo -e "\033[36mArch 󰣇\033[0m"
            pacman -Sy --noconfirm --needed kitty wget unzip curl
        ;;

        *) echo " This is an unknown distribution ."
            return 2
        ;;
    esac

    wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/SourceCodePro.zip

    unzip SourceCodePro.zip -d SourceCodePro

    mkdir -p /home/$USERNAME/.local/share/fonts

    mv SourceCodePro/*.ttf /home/$USERNAME/.local/share/fonts
    chown -R $USERNAME:$USERNAME /home/$USERNAME/.local

    su -c "fc-cache -fv" powder

    rm -rf SourceCodePro SourceCodePro.zip
}

setup_docker() {
    echo -e "\033[36mInstalling Docker .....\033[0m"
    curl -fsSL https://get.docker.com | sh
    if [[ -n $USERNAME ]]; then 
        usermod -aG docker $USERNAME
        echo -e "\033[36m$USERNAME added to docker group\033[0m"
    fi
    echo -e "\033[36mDocker Installed .....\033[0m"
}

setup_user() {

    echo "Setting User ..."
  
    . /etc/os-release

    case $ID in
        debian|ubuntu)
            echo -e "\033[36mDebian  | Ubuntu \033[0m"
            REQUIRED_PKG="sudo"
            PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $REQUIRED_PKG|grep "install ok installed")
            echo Checking for $REQUIRED_PKG: $PKG_OK
            if [ "" = "$PKG_OK" ]; then
                echo "No $REQUIRED_PKG. Setting up $REQUIRED_PKG."  
                apt-get update
                apt-get install $REQUIRED_PKG -y
            fi
        ;;
        fedora)
            echo -e "\033[36mFedora \033[0m"
            dnf install sudo -y
        ;;

        arch)
            echo -e "\033[36mArch 󰣇\033[0m"
            pacman -Sy --noconfirm --needed sudo
        ;;

        *) echo " This is an unknown distribution ."
            return 2
        ;;
    esac

    echo "Enter Username"
    read -r USERNAME
    if [[ -z "$USERNAME" ]]; then echo "\033[31mUSERNAME not set.....\033[0m"; return; fi
    home_dir="/home/$USERNAME"
    home_config="$home_dir/.config"
    fish_config_dir="$home_config/fish"
    kitty_config_dir="$home_config/kitty/"

    sugroup=$(getent group | grep -E "(wheel|sudo)" | head -n1 | cut -d: -f1)
    case $sugroup in
        sudo)
            useradd -m $USERNAME -G sudo
            ;;
        wheel)
            useradd -m $USERNAME -G wheel
            ;;
        *)
            echo "sudo is not ready"
            return 2
            ;;
    esac
    if [[ -d /root/.ssh ]]; then 
        cp -r /root/.ssh /home/$USERNAME/.ssh
        chown -R $USERNAME:$USERNAME /home/$USERNAME/.ssh
    fi
    curl -sS https://starship.rs/install.sh | sh -s -- --yes
    mkdir -p "$fish_config_dir"
    mkdir -p "$kitty_config_dir"
    cp /root/config.fish "$fish_config_dir"/config.fish
    cp /root/kitty.conf "$kitty_config_dir"/kitty.conf
    chown -R "$USERNAME":"$USERNAME" "/home/$USERNAME/"
    starship preset jetpack -o /home/"$USERNAME"/.config/starship.toml
    echo -e "\033[36mUser Created. SSH keys copied. Excecute passwd $USERNAME to setup password\033[0m"
}

setup_wrapper() {
    
    echo -e "\033[33mSetup User  ? (y/n).....\033[0m" 
    read -r choice
    case $choice in
        y|Y|yes|YES)
            setup_user
        ;;
        n|N|no|NO) echo "Skipped..."
        ;;
        *) echo "Invalid input"
        ;;
    esac

    echo -e "\033[33mInstall fish 󰈺 ? (y/n)?\033[0m"
    read -r choice
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

    echo -e "\033[33mInstall neovim  ? (y/n)?\033[0m"
    read -r choice
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

    echo -e "\033[33mInstall Kitty  ? (y/n)?\033[0m"
    read -r choice
    case $choice in 
        y|Y|yes|YES)
            install_kitty
            echo -e "\033[32mKitty installed.....\033[0m"
            ;;
        n|N|no|NO) echo "Skipped Kitty..."
            ;;
        *) echo "Invalid input"
            return 3
            ;;
    esac

    echo -e "\033[33mSetup Docker  ? (y/n).....\033[0m" 
    read -r choice
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
    if [ "$EUID" -ne 0 ]; then
        echo "Error: please run with sudo"
        exit 1
    fi

    if [ -n "$SUDO_USER" ]; then
        echo "Sudo'd by: $SUDO_USER"
        else
        echo "Running as root directly"
    fi

    echo "Running as root "
 
    setup_wrapper
 
    echo -e "\033[32mCompleted\033[0m"
}

main "$@"