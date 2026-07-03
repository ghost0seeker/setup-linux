from re import S
from unittest import TestCase
import docker
from docker.types import Mount
from distros.ubuntu import Ubuntu
from distros.base_distro import BaseDistro
from pathlib import Path


class TestSetupLinux(TestCase):
    
    def setUp(self):
        cwd = Path.cwd()
        self.ubuntu = Ubuntu()
        self.client = docker.from_env()
        self.mounts = [
            Mount(
                target="/root/setup.py",
                source=f'{cwd.resolve()}/setup.py',
                type='bind',
                read_only=True,
            ),
            Mount(
                target='/root/stackscript.sh',
                source=f'{cwd.resolve()}/stackscript.sh',
                type='bind',
                read_only=True
            )
        ]
        
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
    
    def test_ubuntu_docker(self):
        output = self.client.containers.run(
            "ubuntu:24.04",
            "/root/stackscript.sh",
            mounts=self.mounts
        )
        print(output.decode('utf-8'))
    