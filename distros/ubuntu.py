from distros.base_distro import BaseDistro
import pwd
from subprocess import run
from copy import copy as cp
from logging import getLogger

log = getLogger(__name__)

class Ubuntu(BaseDistro):
    def __init__(self):
        self.distro = Ubuntu.__name__.lower()
        self.apt_update = ["sudo", "apt-get", "update"]
        self.apt_upgrade = ["sudo", "apt-get", "upgrade", "-y"]
        self.apt_ppa = ["sudo", "add-apt-repository", "-y"]
        self.apt_install = ["sudo", "apt", "install", "-y"]
        pass
    
    def start(self, args):
        try:
            run(self.apt_update, check=True)
            run(self.apt_upgrade, check=True)
        except Exception:
            log.exception(f"Failed to update {self.distro}")
            return 1
        
        self.install_apps(args.apps)
        self.setup_user(args)
    
    def install_apps(self, apps):
        for app in apps:
            match app:
                case "fish":
                    if not self.install_fish():
                        log.error(f"Failed to install fish on {self.distro}")
                case "nvim":
                    if not self.install_neovim():
                        log.error("Failed to install neovim")
                case "kitty":       
                    if not self.install_kitty():
                        log.error("Failed to install kitty")
                
    def install_neovim(self):
        """
        sudo tar -xzvf - --strip-components=1 --overwrite -C /usr
        """
        nvim_url = "https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz"
        
        nvim_tar_path = BaseDistro.downlaod_file(nvim_url)
        tar_cmd = [f"tar", "-xzf", nvim_tar_path, "--strip-components=1", "--overwrite", "-C", "/usr"]
        try:
            run(tar_cmd, check=True)
            nvim_tar_path.unlink()
            return 0
        except Exception:
            log.exception("Failed to install nvim")
            return 1
        

    def install_fish(self):
        apt_install_dep = cp(self.apt_install)
        apt_install_dep.append("software-properties-common")
        apt_ppa = cp(self.apt_ppa)
        apt_ppa.append("ppa:fish-shell/release-4")
        apt_install_fish = cp(self.apt_install)
        apt_install_fish.append("fish")
        try:
            run(apt_install_dep, check=True)
            run(apt_ppa, check=True)
            run(apt_install_fish, check=True)
        except Exception:
            log.error("Failed to add fish ppa to ubuntu apt")
            return 1
    
    def install_kitty(self):
        kitty_url = "https://sw.kovidgoyal.net/kitty/installer.sh"
        installer: Path = BaseDistro.downlaod_file(kitty_url)
        if installer:
            view =input("View script before exec? ")
            if view:
                print(installer.read_text())
                proceed = input("Proceed with exec? ")
                if proceed.lower() in ["y", "yes"]:
                    BaseDistro.exec_script(installer)
                else:
                    log.info("Installing Canceled")
                    
    def setup_user(self, args):
        try:
            pwd.getpwnam(user)
        except:
            groups = ["sudo", "wheel"]
            if "fish" in args.apps:
                shell = "fish"
            else:
                shell = "bash"
            if "docker" in args.apps:
                groups.append("docker")

    