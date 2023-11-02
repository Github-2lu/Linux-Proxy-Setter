#!/bin/bash
# THis is a simple proxy setter for linux to switch between my hostel and library and manual proxy server

proxy_help()
{
	echo "======================================================"
	echo "-s set proxy"
	echo "-u unset proxy"
	echo "use h for hostel proxy l for library proxy"
	echo "========SYNTAX FOR SETTING PRE-CONFIGURED PROXY======="
	echo "source proxy.sh -s h/l"
	echo "===========SYNTAX FOR SETTING MANUAL PROXY============"
	echo "source proxy.sh -s ip port"
	echo "==============SYNTAX FOR UNSETTING PROXY=============="
	echo "source proxy.sh -u"
	echo "======================================================"
}

remove_keyword() #For removing keyword from file mainly from .bashrc or .zshrc
{
	for var in ${proxy_var[@]}; do
		sed -i "/$var/d" "$1"
	done
	sed -i "/no_proxy/d" "$1"
	sed -i "/NO_PROXY/d" "$1"
}

adding_keyword() #for adding keyword in .bashrc or .zshrc
{
	for var in ${proxy_var[@]}; do
		echo "export $var=http://$1:$2/" >>"$3"
	done
        echo "export no_proxy=localhost,127.0.0.0/8,::1" >> "$3"
        echo "export NO_PROXY=localhost,127.0.0.0/8,::1" >> "$3"
 
}

proxy_set()
{
	gsettings set org.gnome.system.proxy mode 'none' # to set proxy to none to set another proxy
	if [ -f "$bash_loc" ]
	then
		remove_keyword $bash_loc # removing old proxy if any in .bashrc
		adding_keyword $1 $2 $bash_loc # adding new proxy in that file
	fi
	if [ -f "$zsh_loc" ]
	then
		remove_keyword $zsh_loc # similar in zshrc
		adding_keyword $1 $2 $zsh_loc
	fi
	temp_proxy="http://$1:$2/"
	for var in ${proxy_var[@]}; do
		export $var=$temp_proxy # exporting proxy for current session
	done
	export no_proxy=localhost,127.0.0.0/8,::1
	export NO_PROXY=localhost,127.0.0.0/8,::1
#gnome settings to set proxy works for both firefox and chrome if DE is Gnome or Gnome based like cinnamon
	gsettings set org.gnome.system.proxy mode 'manual'
	gsettings set org.gnome.system.proxy.http enabled true
	gsettings set org.gnome.system.proxy.http host $1
	gsettings set org.gnome.system.proxy.http port $2
	gsettings set org.gnome.system.proxy.https host $1
	gsettings set org.gnome.system.proxy.https port $2
	gsettings set org.gnome.system.proxy.ftp host $1
	gsettings set org.gnome.system.proxy.ftp port $2
	gsettings set org.gnome.system.proxy.socks host $1
	gsettings set org.gnome.system.proxy.socks port $2
	gsettings set org.gnome.system.proxy ignore-hosts "['localhost', '127.0.0.0/8', '::1']"
# if DE is kde plasma then this will change settings. ESSENTIAL FOR GOOGLE CHROME TO WORK
	if [ "$DESKTOP_SESSION" = "plasma" ]
	then
		kwriteconfig5 --file kioslaverc --group 'Proxy Settings' --key ProxyType "1"
		kwriteconfig5 --file kioslaverc --group 'Proxy Settings' --key httpProxy "http://$1:$2"
		kwriteconfig5 --file kioslaverc --group 'Proxy Settings' --key httpsProxy "http://$1:$2"
		kwriteconfig5 --file kioslaverc --group 'Proxy Settings' --key ftpProxy "http://$1:$2"
		kwriteconfig5 --file kioslaverc --group 'Proxy Settings' --key socksProxy "http://$1:$2"
		kwriteconfig5 --file kioslaverc --group 'Proxy Settings' --key Authmode 0
		dbus-send --type=signal /KIO/Scheduler org.kde.KIO.Scheduler.reparseSlaveConfiguration string:''
	fi
}

proxy_unset()
{
# unsetting proxy in current session
	for var in  ${proxy_var[@]};do
		unset $var
	done
	unset no_proxy
	unset NO_PROXY
# removing proxies in .bashrc and .zshrc
	if [ -f "$bash_loc" ]
	then
		remove_keyword $bash_loc
	fi
	if [ -f "$zsh_loc" ]
	then
		remove_keyword $zsh_loc
	fi
# unsetting gnome proxy
	gsettings set org.gnome.system.proxy mode 'none'
	echo "[+] proxy is unset"
# unsetting plasma proxy
	if [ "$DESKTOP_SESSION" = "plasma" ]
	then
		if [ -f "$HOME/.config/kioslaverc" ]
		then
			rm "$HOME/.config/kioslaverc"
		fi
	fi
}
# my hostel proxy server
hostel_proxy_set()
{
	temp_ip="10.32.0.1"
	temp_port=8080
	proxy_set $temp_ip $temp_port
	echo "[+] Hostel proxy is set"
}
#my library proxy server
library_proxy_set()
{
	temp_ip="10.11.0.1"
	temp_port=8080
	proxy_set $temp_ip $temp_port
	echo "[+] Library proxy is set"
}


# my .bashrc and .zshrc location
bash_loc="$HOME/.bashrc"
zsh_loc="$HOME/.zshrc"
# proxy variables
proxy_var=("http_proxy" "https_proxy" "ftp_proxy" "HTTP_PROXY" "HTTPS_PROXY" "FTP_PROXY")
echo "Setup is complete"

if [ -f "$bash_loc" ]
then
	if grep -Fwq "http_proxy" $bash_loc
	then proxy_unset
	fi
fi

if [ -f "$zsh_loc" ]
then
	if grep -Fwq "http_proxy" $zsh_loc
	then proxy_unset
	fi
fi

current_wifi="O"

while true
do
	connected_wifi=$(iwgetid -r)
	if [ "$connected_wifi" = "Hostel Aruba" ]
	then
		if [ "$current_wifi" != "H" ]
		then
			current_wifi="H"
			hostel_proxy_set
			echo "Hostel Aruba is connected"
		fi
	else
		if [ "$current_wifi" != "O" ]
		then
			current_wifi="O"
			proxy_unset
			echo "other wifi connected"
		fi
	fi

sleep 1

done

