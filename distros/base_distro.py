import distro
from abc import ABC, abstractmethod
import requests
from pathlib import Path
from datetime import datetime

class BaseDistro(ABC):
    
    @staticmethod
    def get_distro_info():
        return distro.name(), distro.version()
    
    @abstractmethod
    def install_apps(self, apps):
        pass
    
    @abstractmethod
    def start(self, args):
        pass
    
    @staticmethod
    def downlaod_file(url):
        fname = url.split('/')[-1]
        if not fname:
            fname = url.split('/')[-2]
        if not fname:
            fname = "file_" + datetime.now().strftime("%Y-%m-%d_%H:%M")
        file_path = Path(Path.cwd() / fname)
        with requests.get(url, stream=True) as req:
            req.raise_for_status()
            with open(file_path, 'wb') as f:
                for chunk in req.iter_content(chunk_size=8192):
                    f.write(chunk)
        if file_path.is_file():
            return file_path
        else:
            return None
    
    @staticmethod
    def exec_script(self, fp):
        chmod = {"chmod", "+x", fp.resolve()}
        cmd = ["./", fp.resolve()]
        try:
            run(chmod, check=True)
            run(cmd, check=True)
            return 0
            fp.unlink()
        except Exception:
            log.exception(f"Failed to install {fp.name}")
            fp.unlink()
            return 1
        
                       