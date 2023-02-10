# Linux-Proxy-Setter

This is a simple proxy changer script for my hostel and library

firsrt to set proxy for sudo account run sudo visudo in terminal. Enter password. and Enter "Defaults env_keep="http_proxy https_proxy ftp_proxy" under "Defaults env_reset". If env_keep already present then use +=.

run source proxy.sh -h for help

Work in gnome, cinnamon and kde DE.
For xfce as no proxy setting is there so google chrome does not work running this script, but firefox works.
