from unittest import TestCase
import docker
from distros.ubuntu import Ubuntu
from distros.base_distro import BaseDistro

class TestStepLinux(TestCase):
    
    def setUp(self):
        self.ubuntu = Ubuntu()
        
    def test_download_file(self):
        url = "https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz"
        file_path = BaseDistro.downlaod_file(url)
        self.assertNotEqual(file_path, None)
        # file_path.unlink()
    
    def test_install_nvim(self):
        apps = ["nvim"]
        
        self.ubuntu.install_neovim()
    
    def test_install_fish(self):
        apps = ['fish']
        self.ubuntu.install_fish()
        
    def test_install_kitty(self):
        apps = ["kitty"]
        self.ubuntu.install_kitty()
    