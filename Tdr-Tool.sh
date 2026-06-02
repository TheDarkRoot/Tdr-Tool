#!/bin/bash
# -*- coding: utf-8 -*-
spin () {
local pid=$!
local delay=0.10
local spinner=( '\033[34;1m■■■■■■■' '\033[32;1m█\033[33;1m■■■■■■' '\033[33;1m■\033[32;1m█\033[33;1m■■■■■' '\033[33;1m■■\033[32;1m█\033[33;1m■■■■' '\033[33;1m■■■\033[32;1m█\033[33;1m■■■' '\033[33;1m■■■■\033[32;1m█\033[33;1m■■' '\033[33;1m■■■■■\033[32;1m█\033[33;1m■' '\033[33;1m■■■■■■\033[32;1m█' '\033[34;1m■■■■■■■' '\033[33;1m■■■■■■\033[32;1m█' '\033[33;1m■■■■■\033[32;1m█\033[33;1m■' '\033[33;1m■■■■\033[32;1m█\033[33;1m■■' '\033[33;1m■■■\033[32;1m█\033[33;1m■■■' '\033[33;1m■■\033[32;1m█\033[33;1m■■■■' '\033[33;1m■\033[32;1m█\033[33;1m■■■■■' '\033[32;1m█\033[33;1m■■■■■■' )

local msg_loading="$1"
local msg_done="$2"

echo -e ""

while kill -0 $pid 2>/dev/null; do
  for i in "${spinner[@]}"
  do
    echo -ne "\r  $msg_loading $CC【$i$CC】\033[K";
    sleep $delay
  done
done

echo -e "\r  $msg_loading \033[K$msg_done"
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

while true; do
clear;echo -e "
$CC #######$YY ##################$CC #######$YY ####################
$CC    #    #####  #####          #     ####   ####  #
$CC    #    #    # #    #         #    #    # #    # #
$CC    #    #    # #    #  #####  #    #    # #    # #
$CC    #    #    # #####          #    #    # #    # #
$CC    #    #    # #   #          #    #    # #    # #
$CC    #    #####  #    #         #     ####   ####  ######
$YY ###################[›$GG TheDarkRoot $YY‹]###################
$CC =======================================================
$CC ┌⊸⟜┬───⊸ [$MM TheDarkRoot Repositories: $CC]
$CC │  ├─┬─⊸ [$YY›1$YY‹$RR AnonSMS$CC]
$CC │  │ └─⊸ [$YY »$GG Anonymous SMS sending tool.$CC]
$CC │  ├─┬─⊸ [$YY›2$YY‹$RR Hasher$CC]
$CC │  │ └─⊸ [$YY »$GG This is a Hash Cracker.$CC]
$CC │  ├─┬─⊸ [$YY›3$YY‹$RR Hashgen$CC]
$CC │  │ └─⊸ [$YY »$GG Generate more 39 type hash.$CC]
$CC │  ├─┬─⊸ [$YY›4$YY‹$RR Terpack$CC]
$CC │  │ └─⊸ [$YY »$GG TheDarkRoot termux package installer.$CC]
$CC │  ├─┬─⊸ [$YY›5$YY‹$RR Tertest$CC]
$CC │  │ └─⊸ [$YY »$GG Termux internet speed test.$CC]
$CC │  ├─┬─⊸ [$YY›6$YY‹$RR Tertext$CC]
$CC │  │ └─⊸ [$YY »$GG Program for creating words from letters.$CC]
$CC │  └─┬─⊸ [$YY›7$YY‹$RR UserID$CC]
$CC │    └─⊸ [$YY »$GG Search usernames on social media.$CC]
$CC └⊸⟜┬───⊸ [$MM Termux Settings: $CC]
$CC    ├─┬─⊸ [$YY›I$YY‹$RR Internet$CC]
$CC    │ └─⊸ [$YY »$GG Test your internet connection.$CC]
$CC    ├─┬─⊸ [$YY›U$YY‹$RR Update$CC]
$CC    │ └─⊸ [$YY »$GG Termux update.$CC]
$CC    ├─┬─⊸ [$YY›P$YY‹$RR ParrotOS-T$CC]
$CC    │ └─⊸ [$YY »$GG Parrot OS theme for Termux.$CC]
$CC    ├─┬─⊸ [$YY›T$YY‹$RR TheDarkRoot-T$CC]
$CC    │ └─⊸ [$YY »$GG TheDarkRoot theme for Termux.$CC]
$CC    ├─┬─⊸ [$YY›K$YY‹$RR Terkey$CC]
$CC    │ └─⊸ [$YY »$GG Utility to add direction keys to Termux.$CC]
$CC    └─┬─⊸ [$YY›Q$YY‹$RR Exit$CC]
$CC      └─⊸ [$YY »$GG Tdr-Tool exit.$CC]\n"

read -p " $(echo -e " ${CC}[${YY}~${CC}]${MM} Program Number: ${YY}")" pn

	if [[ $pn == U || $pn == u ]]; then
	#Termux Update
	( apt update -y;apt upgrade -y; ) &> /dev/null & spin "$CC[$YY↓$CC]$GG Updating..." " $WW⟫$GG Complete."
	#Termux Packages Installing
	( pkg install ruby git python python2 python3 python-pip php zip unzip cowsay figlet wget curl vim proot crunch neofetch nano cmatrix toilet zsh sl tmate bash tor privoxy -y;pkg install termux-api termux-tools play-audio mpv openssh openssl-tool crunch -y; ) &> /dev/null & spin "$CC[$YY↓$CC]$GG Packages Installing..." " $WW⟫$GG Complete."
	#Termux Tools Installing
	( gem install lolcat;pip3 install --upgrade pip;pip3 install bs4 requests mechanize passlib progressbar2 pillow termcolor speedtest speedtest-cli;pkg install nodejs -y;pkg install nodejs-lts -y;npm install readline-sync;npm install;npm install --global speed-test; ) &> /dev/null & spin "$CC[$YY↓$CC]$GG Tools Installing..." " $WW⟫$GG Complete."
	#Termux Tdr-Tool Updating
	( cd ~/Tdr-Tool/;curl -sLf "https://raw.githubusercontent.com/TheDarkRoot/Tdr-Tool/master/Tdr-Tool.sh?t=$(date +%s)" -o Tdr-Tool.sh; chmod +x Tdr-Tool.sh; ) &> /dev/null & spin "$CC[$YY↓$CC]$GG Tdr-Tool Updating...$YY" " $WW⟫$GG Complete."

	elif [[ $pn == UT || $pn == ut ]]; then
	echo -e "\n $CC [${YY}i$CC]$GG Tdr-Tool: Fast updating program...";
	( cd ~/Tdr-Tool/;curl -sLf "https://raw.githubusercontent.com/TheDarkRoot/Tdr-Tool/master/Tdr-Tool.sh?t=$(date +%s)" -o Tdr-Tool.sh; chmod +x Tdr-Tool.sh; ) &> /dev/null & spin "$CC[$YY↓$CC]$GG Tdr-Tool Updating...$YY" " $WW⟫$GG Complete."

	elif [[ $pn == I || $pn == i ]]; then
	echo -e "\n $CC [${YY}i$CC]$GG Checking internet connection...";

	# İnternet durumunu test ediyoruz
	ping -c 1 8.8.8.8 &> /dev/null
	if [ $? -eq 0 ]; then
		status="$WW⟫$GG ONLINE"
		is_online=true
	else
		status="$WW⟫$RR OFFLINE"
		is_online=false
	fi

	# İnternet kontrol animasyonu dönüyor
	( sleep 1.5 ) &> /dev/null & spin "$CC[$YY↓$CC]$GG Internet control..." "$status"

	# Eğer internet varsa Hız Testi aşamasına geçiyoruz
	if [ "$is_online" = true ]; then
		echo -e ""
		# Kullanıcıya hız testi yapmak isteyip istemediğini soruyoruz
		read -p " $(echo -e " ${CC}[${YY}?${CC}]${MM} Want to run an internet speed test? (Y/n): ${YY}")" st_choice

		if [[ -z $st_choice || $st_choice == Y || $st_choice == y ]]; then
			echo -e "\n $CC [${YY}i$CC]$GG Starting the speed test..."

			# Python veya npm bağımlılığı olmadan doğrudan resmi altyapıyı kullanan saf bash scripti indirip çalıştırıyoruz
			( curl -sL https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py | python3 -W ignore - --simple > .st_result.txt 2>&1 ) & spin "$CC[$YY↓$CC]$GG Testing network speed..." " $WW⟫$GG Complete."

			echo -e "  ${CC}=======================================================${WW}"

			# Dosyadan verileri okuyup renklendirerek ve içeriden başlatarak ekrana basıyoruz
			while IFS= read -r line; do
				if [[ $line == Ping* ]]; then
					# Ping değerini Cyan ikon ve Yeşil metin ile basar
					echo -e "   ${CC}[${YY}✦${CC}]${GG} ${line}"
				elif [[ $line == Download* ]]; then
					# Download değerini Cyan ikon ve Yeşil metin ile basar
					echo -e "   ${CC}[${YY}▼${CC}]${GG} ${line}"
				elif [[ $line == Upload* ]]; then
					# Upload değerini Cyan ikon ve Yeşil metin ile basar
					echo -e "   ${CC}[${YY}▲${CC}]${GG} ${line}"
				else
					# Eğer ekstra bir satır gelirse şablonu bozmasın diye düz yeşil basar
					echo -e "   ${GG}${line}"
				fi
			done < .st_result.txt

			echo -e "  ${CC}=======================================================${WW}"

			# Sonuçları kaydetme aşaması
			read -p " $(echo -e " ${CC}[${YY}?${CC}]${MM} Do you want to save the results to a file? (Y/n): ${YY}")" save_choice

			if [[ -z $save_choice || $save_choice == Y || $save_choice == y ]]; then
				log_file="speedtest_result_$(date +%Y%m%d_%H%M%S).txt"
				mv .st_result.txt ~/Tdr-Tool/"$log_file"
				echo -e "\n  ${CC}[${GG}✓${CC}]${GG} Saved successfully as: ${YY}~/Tdr-Tool/$log_file"
			else
				rm -f .st_result.txt
				echo -e "\n  ${CC}[${RR}x${CC}]${RR} Results deleted."
			fi
		else
			echo -e "\n  ${CC}[${YY}i${CC}]${GG} Speedtest skipped."
		fi
	fi

	elif [[ $pn == P || $pn == p ]]; then
	echo -e "\n $CC [${YY}i$CC]$GG ParrotOS-T: Parrot OS theme for Termux.";
	( cd ~/Tdr-Tool;curl -sLf "https://raw.githubusercontent.com/TheDarkRoot/ParrotOS-T/master/ParrotOS-T.sh?t=$(date +%s)" -o ParrotOS-T.sh;chmod +x ParrotOS-T.sh;bash ParrotOS-T.sh;cd ~/Tdr-Tool;rm -rf ParrotOS-T.sh; ) &> /dev/null & spin "$CC[$YY↓$CC]$GG Downloading ParrotOS-T..." " $WW⟫$GG Complete."

	elif [[ $pn == T || $pn == t ]]; then
	echo -e "\n $CC [${YY}i$CC]$GG TheDarkRoot-T: TheDarkRoot theme for Termux.";
	( cd ~/Tdr-Tool;curl -sLf "https://raw.githubusercontent.com/TheDarkRoot/TheDarkRoot-T/master/TheDarkRoot-T.sh?t=$(date +%s)" -o TheDarkRoot-T.sh;chmod +x TheDarkRoot-T.sh;bash TheDarkRoot-T.sh;cd ~/Tdr-Tool;rm -rf TheDarkRoot-T.sh; ) &> /dev/null & spin "$CC[$YY↓$CC]$GG Downloading TheDarkRoot-T..." " $WW⟫$GG Complete."

	elif [[ $pn == K || $pn == k ]]; then
	echo -e "\n $CC [${YY}i$CC]$GG Terkey: Utility to add direction keys to Termux.";
	( cd ~/Tdr-Tool;curl -sLf "https://raw.githubusercontent.com/TheDarkRoot/Terkey/master/Terkey.sh?t=$(date +%s)" -o Terkey.sh;chmod +x Terkey.sh;bash Terkey.sh;cd ~/Tdr-Tool;rm -rf Terkey.sh; ) &> /dev/null & spin "$CC[$YY↓$CC]$GG Downloading Terkey..." " $WW⟫$GG Complete."

	elif [[ $pn == BASH || $pn == bash ]]; then
	echo -e "\n $CC [${YY}i$CC]$GG Tdr-Tool: TheDarkRoot tool pack.";
	( cd ~/Tdr-Tool/;curl -sLf "https://raw.githubusercontent.com/TheDarkRoot/Tdr-Tool/master/Tdr-Tool.sh?t=$(date +%s)" -o Tdr-Tool.sh;chmod +x Tdr-Tool.sh; ) &> /dev/null & spin "$CC[$YY↓$CC]$GG Downloading Tdr-Tool..." " $WW⟫$GG Complete."

	elif [[ $pn == X || $pn == x ]]; then
	echo -e "\n $CC [${YY}i$CC]$GG X: Code in the trial period.";
	( cd ~/Tdr-Tool && rm -rf .x_temp && git clone --quiet https://github.com/TheDarkRoot/x.git .x_temp && chmod +x .x_temp && chmod +x .x_temp/* && rm -rf x && mv .x_temp x ) &> /dev/null & spin "$CC[$YY↓$CC]$GG Downloading X..."

	elif [[ $pn == 1 || $pn == 01 ]]; then
	echo -e "\n $CC [${YY}i$CC]$GG AnonSMS: Anonymous SMS sending tool.";
	( cd ~/Tdr-Tool && rm -rf .AnonSMS_temp && git clone --quiet https://github.com/TheDarkRoot/AnonSMS.git .AnonSMS_temp && chmod +x .AnonSMS_temp && chmod +x .AnonSMS_temp/* && rm -rf AnonSMS && mv .AnonSMS_temp AnonSMS ) &> /dev/null & spin "$CC[$YY↓$CC]$GG Downloading AnonSMS..." " $WW⟫$GG Complete."

	elif [[ $pn == 2 || $pn == 02 ]]; then
	echo -e "\n $CC [${YY}i$CC]$GG Hasher: This is a Hash Cracker.";
	( cd ~/Tdr-Tool && rm -rf .Hasher_temp && git clone --quiet https://github.com/TheDarkRoot/Hasher.git .Hasher_temp && chmod +x .Hasher_temp && chmod +x .Hasher_temp/* && rm -rf Hasher && mv .Hasher_temp Hasher ) &> /dev/null & spin "$CC[$YY↓$CC]$GG Downloading Hasher..." " $WW⟫$GG Complete."

	elif [[ $pn == 3 || $pn == 03 ]]; then
	echo -e "\n $CC [${YY}i$CC]$GG Hashgen: Generate more 39 type hash.";
	( cd ~/Tdr-Tool && rm -rf .Hashgen_temp && git clone --quiet https://github.com/TheDarkRoot/Hashgen.git .Hashgen_temp && chmod +x .Hashgen_temp && chmod +x .Hashgen_temp/* && rm -rf Hashgen && mv .Hashgen_temp Hashgen ) &> /dev/null & spin "$CC[$YY↓$CC]$GG Downloading Hashgen..." " $WW⟫$GG Complete."

	elif [[ $pn == 4 || $pn == 04 ]]; then
	echo -e "\n $CC [${YY}i$CC]$GG Terpack: TheDarkRoot termux package installer.";
	( cd ~/Tdr-Tool && rm -rf .Terpack_temp && git clone --quiet https://github.com/TheDarkRoot/Terpack.git .Terpack_temp && chmod +x .Terpack_temp && chmod +x .Terpack_temp/* && rm -rf Terpack && mv .Terpack_temp Terpack ) &> /dev/null & spin "$CC[$YY↓$CC]$GG Downloading Terpack..." " $WW⟫$GG Complete."

	elif [[ $pn == 5 || $pn == 05 ]]; then
	echo -e "\n $CC [${YY}i$CC]$GG Tertest: Termux internet speed test.";
	( cd ~/Tdr-Tool && rm -rf .Tertest_temp && git clone --quiet https://github.com/TheDarkRoot/Tertest.git .Tertest_temp && chmod +x .Tertest_temp && chmod +x .Tertest_temp/* && rm -rf Tertest && mv .Tertest_temp Tertest ) &> /dev/null & spin "$CC[$YY↓$CC]$GG Downloading Tertest..." " $WW⟫$GG Complete."

	elif [[ $pn == 6 || $pn == 06 ]]; then
	echo -e "\n $CC [${YY}i$CC]$GG Tertext: Program for creating words from letters.";
	( cd ~/Tdr-Tool && rm -rf .Tertext_temp && git clone --quiet https://github.com/TheDarkRoot/Tertext.git .Tertext_temp && chmod +x .Tertext_temp && chmod +x .Tertext_temp/* && rm -rf Tertext && mv .Tertext_temp Tertext ) &> /dev/null & spin "$CC[$YY↓$CC]$GG Downloading Tertext..." " $WW⟫$GG Complete."

	elif [[ $pn == 7 || $pn == 07 ]]; then
	echo -e "\n $CC [${YY}i$CC]$GG UserID: Search usernames on social media.";
	( cd ~/Tdr-Tool && rm -rf .UserID_temp && git clone --quiet https://github.com/TheDarkRoot/UserID.git .UserID_temp && chmod +x .UserID_temp && chmod +x .UserID_temp/* && rm -rf UserID && mv .UserID_temp UserID ) &> /dev/null & spin "$CC[$YY↓$CC]$GG Downloading UserID..." " $WW⟫$GG Complete."

	elif [[ $pn == Q || $pn == q ]]; then
	echo -e "\n $CC [$YY»$CC]$RR Good Bye...";
	sleep 0;exit;

	else
	echo -e "\n  ${YY}[${RR}⦸${YY}]${RR} Invalid Action."	
	sleep 1

    fi

	if [[ $pn != Q && $pn != q && $pn != "" ]]; then
        if [[ $pn =~ ^(U|u|UT|ut|P|p|T|t|K|k|BASH|bash|X|x|[1-7]|0[1-7]|I|i)$ ]]; then

            read -n 1 -s -p " $(echo -e "\n  ${CC}[${YY}~${CC}]${MM} Press any key to return to main menu...${YY}")"

            if [[ $pn == U || $pn == u || $pn == UT || $pn == ut ]]; then
                exec bash ~/Tdr-Tool/Tdr-Tool.sh
            fi
        fi
    fi
done