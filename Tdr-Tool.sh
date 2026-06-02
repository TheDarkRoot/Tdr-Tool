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

run_speedtest () {
	echo -e "\n $CC [${YY}i$CC]$GG Starting the speed test..."

	# Ham verileri filtreleyebilmek için normal çıktı alıyoruz ve uyarıları gizliyoruz
	( curl -sL https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py | python3 -W ignore - > .st_raw.txt 2>&1 ) & spin "$CC[$YY↓$CC]$GG Testing network speed..." " $WW⟫$GG Complete."

	# Alınan ham verileri ayıklıyoruz
	my_ip=$(grep -oE "Testing from .* \([0-9.]+\)" .st_raw.txt | grep -oE "[0-9.]+" | head -n 1)
	provider=$(grep -oE "Testing from .* \(" .st_raw.txt | sed 's/Testing from //' | sed 's/ ($//' | sed 's/ (//')
	server_info=$(grep "Hosted by" .st_raw.txt | sed 's/Hosted by //' | cut -d '[' -f1 | sed 's/ *$//')
	
	# Ping ayıklama yapısı
	ping_val=$(grep "Hosted by" .st_raw.txt | grep -oE "\[[0-9.]+ ms\]" | sed 's/\[//g' | sed 's/\]//g')
	[[ -z $ping_val ]] && ping_val=$(grep "Hosted by" .st_raw.txt | grep -oE "[0-9.]+ ms")
	
	dl_val=$(grep "Download:" .st_raw.txt | sed 's/Download: //')
	ul_val=$(grep "Upload:" .st_raw.txt | sed 's/Upload: //')

	# Değerleri sayısal formata çevirip kalite kontrolü yapıyoruz
	dl_num=$(echo "$dl_val" | awk '{print $1}')
	ul_num=$(echo "$ul_val" | awk '{print $1}')
	ping_num=$(echo "$ping_val" | awk '{print $1}')

	[[ -z $dl_num ]] && dl_num=0
	[[ -z $ul_num ]] && ul_num=0
	[[ -z $ping_num ]] && ping_num=0

	# Dinamik Kalite Hesaplama Alanı
	b_qual="$RR Poor" && g_qual="$RR Poor" && s_qual="$RR Poor" && v_qual="$RR Poor"

	# Browsing (Webde Gezinme) Kalitesi
	if (( $(echo "$dl_num >= 15" | bc -l) )); then b_qual="$GG Great"; elif (( $(echo "$dl_num >= 5" | bc -l) )); then b_qual="$YY Good"; fi
	# Gaming (Oyun) Kalitesi
	if (( $(echo "$ping_num <= 30 && $ping_num > 0" | bc -l) && $(echo "$ul_num >= 5" | bc -l) )); then g_qual="$GG Great"; elif (( $(echo "$ping_num <= 60" | bc -l) )); then g_qual="$YY Good"; fi
	# Streaming (Video İzleme) Kalitesi
	if (( $(echo "$dl_num >= 25" | bc -l) )); then s_qual="$GG Great"; elif (( $(echo "$dl_num >= 10" | bc -l) )); then s_qual="$YY Good"; fi
	# Video Call (Görüntülü Görüşme) Kalitesi
	if (( $(echo "$ul_num >= 8" | bc -l) && $(echo "$ping_num <= 40" | bc -l) )); then v_qual="$GG Great"; elif (( $(echo "$ul_num >= 3" | bc -l) )); then v_qual="$YY Good"; fi

	# Orijinal .st_result.txt dosyasını kaydetmek üzere düz metin hazırlıyoruz
	echo -e "IP Address: $my_ip\nProvider: $provider\nServer: $server_info\nPing: $ping_val\nDownload: $dl_val\nUpload: $ul_val" > .st_result.txt

	# EKRANA RENKLİ RAPOR BASKI ALANI
	echo -e "  ${CC}=======================================================${WW}"
	echo -e "   ${CC}[${YY}WAN${CC}]${GG} IP Address : ${YY}$my_ip"
	echo -e "   ${CC}[${YY}ISP${CC}]${GG} Provider   : ${YY}$provider"
	echo -e "   ${CC}[${YY}SRV${CC}]${GG} Server     : ${YY}$server_info"
	echo -e "   ${CC}[${YY}LAT${CC}]${GG} Ping       : ${YY}$ping_val"
	echo -e "   ${CC}[${YY}OUT${CC}]${GG} Download   : ${YY}$dl_val"
	echo -e "   ${CC}[${YY}INP${CC}]${GG} Upload     : ${YY}$ul_val"
	echo -e "  ${CC}-------------------------------------------------------${WW}"
	echo -e "   ${CC}[${YY}»${CC}]${MM} Browsing Quality  : ${b_qual}"
	echo -e "   ${CC}[${YY}»${CC}]${MM} Gaming Quality    : ${g_qual}"
	echo -e "   ${CC}[${YY}»${CC}]${MM} Streaming Quality : ${s_qual}"
	echo -e "   ${CC}[${YY}»${CC}]${MM} Video Call Quality: ${v_qual}"
	echo -e "  ${CC}=======================================================${WW}"

	rm -f .st_raw.txt

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
}

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
	#Termux Permissions
	( termux-setup-storage; termux-wake-lock; sleep 3 ) &> /dev/null & spin "$CC[$YY↓$CC]$GG Permission..." " $WW⟫$GG Complete."
	#Termux Update
	( apt update -y;apt upgrade -y; ) &> /dev/null & spin "$CC[$YY↓$CC]$GG Updating..." " $WW⟫$GG Complete."
	#Termux Packages Installing
	( pkg install termux-tools termux-api coreutils binutils -y; pkg install git curl wget sed grep awk bc jq ncurses-utils -y; pkg install python python-pip ruby php -y; pkg install clang make openssh openssl openssl-tool -y; pkg install zip unzip tar proot crunch -y; pkg install neofetch nano vim cmatrix sl tmate zsh bash tor privoxy play-audio mpv cowsay figlet toilet -y; ) &> /dev/null & spin "$CC[$YY↓$CC]$GG Packages Installing..." " $WW⟫$GG Complete."
	#Termux Tools Installing
	( 
	  # 1. Pip Yükseltme ve Temel Kütüphaneler
	  pip install --upgrade pip setuptools wheel;
	  
	  # 2. Python tabanlı araçlar (İnternet ve güvenlik kütüphaneleri)
	  pip install bs4 requests mechanize passlib progressbar2 pillow termcolor speedtest-cli;
	  
	  # 3. Node.js ve NPM paketleri
	  pkg install nodejs -y;
	  npm install -g npm@latest; # NPM'i en güncel sürüme çeker
	  npm install -g readline-sync speed-test;
	  
	  # 4. Ruby araçları
	  gem install lolcat;
	) &> /dev/null & spin "$CC[$YY↓$CC]$GG Tools Installing..." " $WW⟫$GG Complete."
	#Termux Tdr-Tool Updating
	( cd ~/Tdr-Tool/;curl -sLf "https://raw.githubusercontent.com/TheDarkRoot/Tdr-Tool/master/Tdr-Tool.sh?t=$(date +%s)" -o Tdr-Tool.sh; chmod +x Tdr-Tool.sh; ) &> /dev/null & spin "$CC[$YY↓$CC]$GG Tdr-Tool Updating...$YY" " $WW⟫$GG Complete."

	elif [[ $pn == AIO || $pn == aio ]]; then
	echo -e "\n $CC [${YY}i$CC]$GG Starting AIO (All-in-One) Configuration..."

	ping -c 1 8.8.8.8 &> /dev/null
	if [ $? -eq 0 ]; then
		echo -e " $CC [$GG✓$CC]$GG Internet connection detected. Starting automation..."
		#Termux Permissions
		( termux-setup-storage; termux-wake-lock; sleep 3 ) &> /dev/null & spin "$CC[$YY↓$CC]$GG Permission..." " $WW⟫$GG Complete."
		#Termux Update
		( apt update -y;apt upgrade -y; ) &> /dev/null & spin "$CC[$YY↓$CC]$GG Updating..." " $WW⟫$GG Complete."
		#Termux Packages Installing
		( pkg install termux-tools termux-api coreutils binutils -y; pkg install git curl wget sed grep awk bc jq ncurses-utils -y; pkg install python python-pip ruby php -y; pkg install clang make openssh openssl openssl-tool -y; pkg install zip unzip tar proot crunch -y; pkg install neofetch nano vim cmatrix sl tmate zsh bash tor privoxy play-audio mpv cowsay figlet toilet -y; ) &> /dev/null & spin "$CC[$YY↓$CC]$GG Packages Installing..." " $WW⟫$GG Complete."
		#Termux Tools Installing
		(
		  pip install --upgrade pip setuptools wheel;
		  pip install bs4 requests mechanize passlib progressbar2 pillow termcolor speedtest-cli;
		  pkg install nodejs -y;
		  npm install -g npm@latest;
		  npm install -g readline-sync speed-test;
		  gem install lolcat;
		) &> /dev/null & spin "$CC[$YY↓$CC]$GG Tools Installing..." " $WW⟫$GG Complete."
		#Termux Tdr-Tool Updating
		( cd ~/Tdr-Tool/;curl -sLf "https://raw.githubusercontent.com/TheDarkRoot/Tdr-Tool/master/Tdr-Tool.sh?t=$(date +%s)" -o Tdr-Tool.sh; chmod +x Tdr-Tool.sh; ) &> /dev/null & spin "$CC[$YY↓$CC]$GG Tdr-Tool Updating...$YY" " $WW⟫$GG Complete."

		echo -e "\n $CC [$YY!$CC]$GG AIO Configuration finished! Starting Final Speed Test..."
		# Ortak fonksiyonu otomatik olarak çağırıyoruz
		run_speedtest

	else
		echo -e "\n $CC [$RR!$CC]$RR AIO Failed: No Internet connection."
	fi

	elif [[ $pn == UT || $pn == ut ]]; then
	echo -e "\n $CC [${YY}i$CC]$GG Tdr-Tool: Fast updating program...";
	( cd ~/Tdr-Tool/;curl -sLf "https://raw.githubusercontent.com/TheDarkRoot/Tdr-Tool/master/Tdr-Tool.sh?t=$(date +%s)" -o Tdr-Tool.sh; chmod +x Tdr-Tool.sh; ) &> /dev/null & spin "$CC[$YY↓$CC]$GG Tdr-Tool Updating...$YY" " $WW⟫$GG Complete."

	elif [[ $pn == I || $pn == i ]]; then
	echo -e "\n $CC [${YY}i$CC]$GG Checking internet connection...";

	ping -c 1 8.8.8.8 &> /dev/null
	if [ $? -eq 0 ]; then
		status="$WW⟫$GG ONLINE"
		is_online=true
	else
		status="$WW⟫$RR OFFLINE"
		is_online=false
	fi

	( sleep 1.5 ) &> /dev/null & spin "$CC[$YY↓$CC]$GG Internet control..." "$status"

	if [ "$is_online" = true ]; then
		echo -e ""
		read -p " $(echo -e " ${CC}[${YY}?${CC}]${MM} Want to run an internet speed test? (Y/n): ${YY}")" st_choice

		if [[ -z $st_choice || $st_choice == Y || $st_choice == y ]]; then
			# Ortak fonksiyonu çağırıyoruz
			run_speedtest
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
        if [[ $pn =~ ^(U|u|UT|ut|AIO|aio|P|p|T|t|K|k|X|x|[1-7]|0[1-7]|I|i)$ ]]; then

            read -n 1 -s -p " $(echo -e "\n  ${CC}[${YY}~${CC}]${MM} Press any key to return to main menu...${YY}")"

            if [[ $pn == U || $pn == u || $pn == UT || $pn == ut || $pn == AIO || $pn == aio ]]; then
                exec bash ~/Tdr-Tool/Tdr-Tool.sh
            fi
        fi
    fi
done