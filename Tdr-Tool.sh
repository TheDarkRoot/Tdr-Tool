#!/bin/bash
spin () {
local pid=$!
local delay=0.10
local spinner=( '\033[34;1m■■■■■■■' '\033[32;1m█\033[33;1m■■■■■■' '\033[33;1m■\033[32;1m█\033[33;1m■■■■■' '\033[33;1m■■\033[32;1m█\033[33;1m■■■■' '\033[33;1m■■■\033[32;1m█\033[33;1m■■■' '\033[33;1m■■■■\033[32;1m█\033[33;1m■■' '\033[33;1m■■■■■\033[32;1m█\033[33;1m■' '\033[33;1m■■■■■■\033[32;1m█' '\033[34;1m■■■■■■■' '\033[33;1m■■■■■■\033[32;1m█' '\033[33;1m■■■■■\033[32;1m█\033[33;1m■' '\033[33;1m■■■■\033[32;1m█\033[33;1m■■' '\033[33;1m■■■\033[32;1m█\033[33;1m■■■' '\033[33;1m■■\033[32;1m█\033[33;1m■■■■' '\033[33;1m■\033[32;1m█\033[33;1m■■■■■' '\033[32;1m█\033[33;1m■■■■■■' )

while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do

for i in "${spinner[@]}"
do
  echo -ne "\r$CC [$YY↓$CC]$YY Downloading please wait...$CC 【$i$CC】";
  sleep $delay
  printf "\b\b\b\b\b\b\b\b";
done
done
printf "   \b\b\b\b\b"
printf "$WW⟫$GG Completed.\n";
echo "";
}
#Colors
BB="\033[34;1m" # Blue Light
YY="\033[33;1m" # Yellow Light
GG="\033[32;1m" # Green Light
WW="\033[0;1m"  # White Light
RR="\033[31;1m" # Red Light
CC="\033[36;1m" # Cyan Light
MM="\033[35;1m" # Magenta Light
B="\033[34;1m"  # Blue
Y="\033[33;1m"  # Yellow
G="\033[32;1m"  # Green
W="\033[0;1m"   # White
R="\033[31;1m"  # Red
C="\033[36;1m"  # Cyan
M="\033[35;1m"  # Magenta
clear;
echo -e "\n$CC #######$YY ##################$CC #######$YY ####################
$CC    #    #####  #####          #     ####   ####  #
$CC    #    #    # #    #         #    #    # #    # #
$CC    #    #    # #    #  #####  #    #    # #    # #
$CC    #    #    # #####          #    #    # #    # #
$CC    #    #    # #   #          #    #    # #    # #
$CC    #    #####  #    #         #     ####   ####  ######
$YY ####################[$GG TheDarkRoot$YY ]####################\n
$CC =======================================================\n
$GG >_TheDarkRoot Repositories:\n
$YY    [\033[0;1m1$YY]$GG AnonSMS
$YY    [\033[0;1m2$YY]$GG Hasher
$YY    [\033[0;1m3$YY]$GG Hashgen
$YY    [\033[0;1m4$YY]$GG Terpack
$YY    [\033[0;1m5$YY]$GG UserID\n
$GG >_Termux Settings:\n
$YY    [\033[0;1mU$YY]$GG Update   =$CC [\033[33;1mi$CC]$GG Termux update.
$YY    [\033[0;1mT$YY]$GG ParrotOS =$CC [\033[33;1mi$CC]$GG Parrot OS theme for Termux.
$YY    [\033[0;1mK$YY]$GG Terkey   =$CC [\033[33;1mi$CC]$GG Utility to add direction keys to Termux.
$YY    [\033[0;1mE$YY]$GG Exit     =$CC [\033[33;1mi$CC]$GG Termux exit.$YY\n"
read -p " [*] Program Number: " pn
if [[ $pn == U || $pn == u ]]; then
clear;echo -e "$CC\n [$YY↓$CC]$GG Updating...\n";apt update;apt upgrade -y;clear;
echo -e "$CC [$YY*$CC]$GG Termux setup storage...$YY";
( termux-setup-storage; ) &> /dev/null & spin;
echo -e "$CC [$YY*$CC]$GG Pkg installing...$YY";
( pkg install git -y;pkg install python -y;pkg install python2;pkg install ruby -y;pkg install php -y;pkg install cowsay -y;pkg install figlet;pkg install toilet -y;pkg install wget -y;pkg install curl -y;pkg install vim -y;pkg install proot;pkg install crunch;pkg install neofetch;pkg install nano;pkg install cmatrix;pkg install openssh -y;pkg install zsh;pkg install termux-api; ) &> /dev/null & spin;
echo -e "$CC [$YY*$CC]$GG Pip installing...$YY";
( gem install lolcat;pip install --upgrade pip;pip2 install --upgrade pip;pip install bs4;pip2 install bs4;pip install requests;pip2 install requests;pip install mechanize;pip2 install mechanize;pip2 install passlib;pip2 install progressbar;pip install pillow; ) &> /dev/null & spin;
bash Tdr-Tool.sh

elif [[ $pn == T || $pn == t ]]; then
        echo -e "\n$CC [$YY*$CC]$GG Updating Parrot OS theme...\n$CC [\033[33;1mi$CC]$GG Parrot OS theme for Termux.";
		( curl https://raw.githubusercontent.com/TheDarkRoot/ParrotOS-T/main/ParrotOS-T.sh -o ParrotOS-T.sh;chmod +x ParrotOS-T.sh;bash ParrotOS-T.sh; ) &> /dev/null & spin;
	cd ~/Tdr-Tool
        bash Tdr-Tool.sh

elif [[ $pn == K || $pn == k ]]; then
        echo -e "\n$CC [$YY*$CC]$GG Updating Termux key...\n$CC [\033[33;1mi$CC]$GG Utility to add direction keys to Termux.";
		( cd ~/Tdr-Tool;git clone https://github.com/TheDarkRoot/AnonSMS.git;cd AnonSMS;chmod +x *; ) &> /dev/null & spin;
	cd ~/Tdr-Tool
        bash Tdr-Tool.sh

elif [[ $pn == E || $pn == e ]]; then
        echo -e "\n$CC [$YY*$CC]$RR Good bye...$YY\n";
		sleep 3;exit;

elif [[ $pn == 1 || $pn == 01 ]]; then
        echo -e "\n$CC [$YY*$CC]$GG Downloading AnonSMS...\n$CC [\033[33;1mi$CC]$GG Anonymous SMS sending tool.";
		( cd ~/Tdr-Tool;git clone https://github.com/TheDarkRoot/AnonSMS.git;cd AnonSMS;chmod +x *; ) &> /dev/null & spin;
	cd ~/Tdr-Tool
        bash Tdr-Tool.sh

elif [[ $pn == 2 || $pn == 02 ]]; then
        echo -e "\n$CC [$YY*$CC]$GG Downloading Hasher...\n$CC [\033[33;1mi$CC]$GG Hasher is a Hash Cracker that has supported more than 7 types of hashes.";
		( cd ~/Tdr-Tool;git clone https://github.com/TheDarkRoot/Hasher.git;cd Hasher;chmod +x *; ) &> /dev/null & spin;
	cd ~/Tdr-Tool
        bash Tdr-Tool.sh

elif [[ $pn == 3 || $pn == 03 ]]; then
        echo -e "\n$CC [$YY*$CC]$GG Downloading Hashgen...\n$CC [\033[33;1mi$CC]$GG Generate more 39 type hash.";
		( cd ~/Tdr-Tool;git clone https://github.com/TheDarkRoot/Hashgen.git;cd Hashgen;chmod +x *; ) &> /dev/null & spin;
	cd ~/Tdr-Tool
        bash Tdr-Tool.sh

elif [[ $pn == 4 || $pn == 04 ]]; then
        echo -e "\n$CC [$YY*$CC]$GG Downloading Terpack...\n$CC [\033[33;1mi$CC]$GG TheDarkRoot termux package installer.";
		( cd ~/Tdr-Tool;git clone https://github.com/TheDarkRoot/Terpack.git;cd Terpack;chmod +x *; ) &> /dev/null & spin;
	cd ~/Tdr-Tool
        bash Tdr-Tool.sh

elif [[ $pn == 5 || $pn == 05 ]]; then
        echo -e "\n$CC [$YY*$CC]$GG Downloading UserID...\n$CC [\033[33;1mi$CC]$GG Search for usernames on more than 75 social media.";
		( cd ~/Tdr-Tool;git clone https://github.com/TheDarkRoot/UserID.git;cd UserID;chmod +x *; ) &> /dev/null & spin;
	cd ~/Tdr-Tool
        bash Tdr-Tool.sh

else
	clear
        echo -e '\n   \033[33;1m[\033[31;1mX\033[33;1m]\033[31;1m Invalid action.\n'	
	sleep 2
	clear
	bash Tdr-Tool.sh
fi
