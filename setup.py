import sys
import distro
import argparse
from distros.base_distro import BaseDistro
from distros.ubuntu import Ubuntu
import logging
from dotenv import load_dotenv
from os import environ

env_get = environ.get

load_dotenv()
LOG_LEVEL = env_get("LOG_LEVEL", "INFO")

logging.basicConfig(
    level = LOG_LEVEL,
    force=True
)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="")

    parser.add_argument("--apps", required=True, nargs='+', help="Apps to install", type=str)
    parser.add_argument("--user", required=True, help="User to setup", type=str)

    args = parser.parse_args()

    name, version = BaseDistro.get_distro_info()
    
    for cls in  BaseDistro.__subclasses__():
        if cls.__name__.lower() == name.lower():
            distro_obj = cls()
            
            distro_obj.start(args)
        else:
            print("Unsupported Distro")
            
        
        

