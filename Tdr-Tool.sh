#!/usr/bin/env bash
# -*- coding: utf-8 -*-
# Color
B='\033[34;1m'  # Blue Light
Y='\033[33;1m'  # Yellow Light
G='\033[32;1m'  # Green Light
W='\033[0;1m'   # White Light
R='\033[31;1m'  # Red Light
C='\033[36;1m'  # Cyan Light
M='\033[35;1m'  # Magenta Light

Etc="$PREFIX/etc/" #/data/data/com.termux/files/usr/etc/
Termux="$HOME/.termux/" #/data/data/com.termux/files/home/
Tool="$HOME/Tdr-Tool/" #/data/data/com.termux/files/home/
Github="https://github.com"
TheDarkRoot="https://github.com/TheDarkRoot"
Raw="https://raw.githubusercontent.com/TheDarkRoot"
Reload="termux-reload-settings"

# 1. Termux Depolama İzni Kontrolü
if [ ! -d "$HOME/storage" ]; then
    termux-setup-storage
    sleep 5
	$Reload
fi

# 2. Gerekli Tüm Klasörlerin Oluşturulması
# İleride yeni bir klasör eklemek istersen sadece bu listeye yolunu yazman yeterli!
setup_folders=(
    "$Tool"
    "$Termux"
)

for dir in "${setup_folders[@]}"; do
    if [ ! -d "$dir" ]; then
        mkdir -p "$dir"
    fi
done

case "$1" in
    -i)
        echo -e "
${C} #######${Y} ##################${C} #######${Y} ####################
${C}    #    #####  #####          #     ####   ####  #
${C}    #    #    # #    #         #    #    # #    # #
${C}    #    #    # #    #  #####  #    #    # #    # #
${C}    #    #    # #####          #    #    # #    # #
${C}    #    #    # #   #          #    #    # #    # #
${C}    #    #####  #    #         #     ####   ####  ######
${Y} ###################[›${G} TheDarkRoot ${Y}‹]###################
${C} -------------------------------------------------------
${G} 0{======================${W} INFO ${G}=======================}0
${G} |${Y} [${C}=${Y}]${W} Name     ${C}:${W} Tdr-Tool$GG                             |
${G} |${Y} [${C}=${Y}]${W} Code     ${C}:${W} Shell$GG                                |
${G} |${Y} [${C}=${Y}]${W} Version  ${C}:${W} v1.2.7 (Alpha)$GG                       |
${G} |${Y} [${C}=${Y}]${W} Author   ${C}:${W} Tdr-Tool$GG                             |
${G} |${Y} [${C}=${Y}]${W} Github   ${C}:${W} https://github.com/TheDarkRoot$GG       |
${G} |${Y} [${C}=${Y}]${W} Telegram ${C}:${W} @TheDarkRoot (t.me/TheDarkRoot)$GG      |
${G} 0{===================================================}0\n"
        exit 0
        ;;
    *)
        # Eğer parametre yoksa veya tanınmıyorsa menüye devam et
        ;;
esac

install_missing_packages() {
    local missing_pkgs=()
    # Girdi olarak verilen tüm paketleri kontrol et
    for pkg in "$@"; do
        # dpkg ile paketin kurulu olup olmadığına bak
        if ! dpkg -s "$pkg" &> /dev/null; then
            missing_pkgs+=("$pkg")
        fi
    done

    # Sadece eksik paket varsa kurulum komutunu çalıştır
    if [ ${#missing_pkgs[@]} -gt 0 ]; then
        pkg install -y "${missing_pkgs[@]}"
    fi
}

install_tool() {
    local tool_name="$1"
    # Geçici klasörü temizle ve yeni sürümü klonla
    cd "$Tool" && rm -rf ".${tool_name}_temp" && \
    git clone --quiet "$TheDarkRoot/$tool_name.git" ".${tool_name}_temp" && \
    rm -rf "$tool_name" && mv ".${tool_name}_temp" "$tool_name" && \
    chmod +x "$tool_name" && chmod +x "$tool_name"/*
}

run_update () {
	echo -e "\n ${C} [${Y}i${C}]${G} Starting the update..."
	#Termux Permissions
	( termux-setup-storage; termux-wake-lock && $Reload; sleep 3 ) &>> ~/.TermuxPermissions_debug.log & spin "${C}[${Y}↓${C}]${G} Permission..." " ${W}⟫${G} Complete."
	#Termux Update
	( echo "--- Updating ---" > "$Log"; pkg update -y; pkg upgrade -y && $Reload; ) &>> ~/.TermuxUpdate_debug.log & spin "${C}[${Y}↓${C}]${G} Updating..." " ${W}⟫${G} Complete."
	#Termux Packages Installing
	( install_missing_packages termux-tools coreutils binutils git curl wget sed grep gawk bc jq ncurses-utils python ruby php clang make openssh openssl zip unzip tar proot crunch neofetch nano vim cmatrix sl tmate zsh bash tor privoxy play-audio mpv cowsay figlet toilet nodejs && $Reload; ) &>> ~/.TermuxPackages_debug.log & spin "${C}[${Y}↓${C}]${G} Packages Installing..." " ${W}⟫${G} Complete."
	#Termux Tools Installing
	(
	  pip install --upgrade pip setuptools wheel bs4 requests mechanize passlib progressbar2 pillow termcolor speedtest-cli;
	  npm install -g npm@latest readline-sync speed-test;
	  gem install lolcat && $Reload;
	) &>> ~/.TheDarkRoot_debug.log & spin "${C}[${Y}↓${C}]${G} Tools Installing..." " ${W}⟫${G} Complete."
	#Termux Tdr-Tool Updating
	(
	 cd ~/ && curl -sLf "$Raw/Tdr-Tool/master/Tdr-Tool.sh?t=$(date +%s)" -o Tdr-Tool_temp.sh;
	 rm -rf  Tdr-Tool.sh && mv Tdr-Tool_temp.sh Tdr-Tool.sh && chmod +x Tdr-Tool.sh;
	) &> ~/.TheDarkRootTool_debug.log & spin "${C}[${Y}↓${C}]${G} Tdr-Tool Updating...${Y}" " ${W}⟫${G} Complete."
}

run_speedtest () {
	# Bağımlılık Kontrolü
    local dependencies=("python3" "awk" "bc" "curl")
    for cmd in "${dependencies[@]}"; do
        if ! command -v "$cmd" &> /dev/null; then
            echo -e "\n  ${C}[${R}!${C}]${R} Error: '$cmd' package missing!"
            echo -e "\n  ${C}[${Y}i${C}]${G} You can install packages with the 'U' Update option."
            return 1 # Fonksiyonu iptal et ve menüye dön
        fi
    done

    # Çakışmaları önlemek için benzersiz geçici dosyaları oluşturuyoruz
    local RAW_FILE=$(mktemp)
    local RESULT_FILE=$(mktemp)

	# Ham verileri filtreleyebilmek için normal çıktı alıyoruz ve uyarıları gizliyoruz
	(
		if command -v speedtest-cli &> /dev/null; then
			speedtest-cli > "$RAW_FILE" 2>&1
		else
			curl -sL https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py | python3 -W ignore - > "$RAW_FILE" 2>&1
		fi
	) & spin "${C}[${Y}↓${C}]${G} Testing network speed..." " ${W}⟫${G} Complete."

	# --- GÜVENLİK KİLİDİ BAŞLANGICI ---
	# İşlem başarısız olduysa VEYA geçerli bir indirme verisi gelmediyse işlemi iptal et
	if [ $? -ne 0 ] || ! grep -q "Download:" "$RAW_FILE"; then
		echo -e "\n  ${C}[${R}!${C}]${R} Cut! Please check your network connection."
		rm -f "$RAW_FILE" "$RESULT_FILE"
		return 1
	fi

	# Alınan ham verileri RAW_FILE üzerinden ayıklıyoruz
	my_ip=$(grep -oE "Testing from .* \([0-9.]+\)" "$RAW_FILE" | grep -oE "[0-9.]+" | head -n 1)
	provider=$(grep -oE "Testing from .* \(" "$RAW_FILE" | sed 's/Testing from //' | sed 's/ ($//' | sed 's/ (//')
	server_info=$(grep "Hosted by" "$RAW_FILE" | sed 's/Hosted by //' | cut -d '[' -f1 | sed 's/ *$//')

	# Ping ayıklama yapısı
	ping_val=$(grep "Hosted by" "$RAW_FILE" | grep -oE "\[[0-9.]+ ms\]" | sed 's/\[//g' | sed 's/\]//g')
	[[ -z $ping_val ]] && ping_val=$(grep "Hosted by" "$RAW_FILE" | grep -oE "[0-9.]+ ms")

	dl_val=$(grep "Download:" "$RAW_FILE" | sed 's/Download: //')
	ul_val=$(grep "Upload:" "$RAW_FILE" | sed 's/Upload: //')

	# Değerleri sayısal formata çevirip kalite kontrolü yapıyoruz
	dl_num=$(echo "$dl_val" | awk '{print $1}')
	ul_num=$(echo "$ul_val" | awk '{print $1}')
	ping_num=$(echo "$ping_val" | awk '{print $1}')

	[[ -z $dl_num ]] && dl_num=0
	[[ -z $ul_num ]] && ul_num=0
	[[ -z $ping_num ]] && ping_num=0

	# Dinamik Kalite Hesaplama Alanı
	b_qual="${R} Poor" && g_qual="${R} Poor" && s_qual="${R} Poor" && v_qual="${R} Poor"

	# Browsing (Webde Gezinme) Kalitesi
	if (( $(echo "$dl_num >= 15" | bc -l) )); then b_qual="${G} Great"; elif (( $(echo "$dl_num >= 5" | bc -l) )); then b_qual="${Y} Good"; fi
	# Gaming (Oyun) Kalitesi
	if (( $(echo "$ping_num <= 30 && $ping_num > 0" | bc -l) && $(echo "$ul_num >= 5" | bc -l) )); then g_qual="${G} Great"; elif (( $(echo "$ping_num <= 60" | bc -l) )); then g_qual="${Y} Good"; fi
	# Streaming (Video İzleme) Kalitesi
	if (( $(echo "$dl_num >= 25" | bc -l) )); then s_qual="${G} Great"; elif (( $(echo "$dl_num >= 10" | bc -l) )); then s_qual="${Y} Good"; fi
	# Video Call (Görüntülü Görüşme) Kalitesi
	if (( $(echo "$ul_num >= 8" | bc -l) && $(echo "$ping_num <= 40" | bc -l) )); then v_qual="${G} Great"; elif (( $(echo "$ul_num >= 3" | bc -l) )); then v_qual="${Y} Good"; fi

	# Sonucu kaydetmek üzere düz metin hazırlıyoruz
	echo -e "IP Address: $my_ip\nProvider: $provider\nServer: $server_info\nPing: $ping_val\nDownload: $dl_val\nUpload: $ul_val" > "$RESULT_FILE"

	# EKRANA RENKLİ RAPOR BASKI ALANI
	echo -e "  ${C}=======================================================${W}"
	echo -e "   ${C}[${Y}WAN${C}]${G} IP Address : ${Y}$my_ip"
	echo -e "   ${C}[${Y}ISP${C}]${G} Provider   : ${Y}$provider"
	echo -e "   ${C}[${Y}SRV${C}]${G} Server     : ${Y}$server_info"
	echo -e "   ${C}[${Y}LAT${C}]${G} Ping       : ${Y}$ping_val"
	echo -e "   ${C}[${Y}OUT${C}]${G} Download   : ${Y}$dl_val"
	echo -e "   ${C}[${Y}INP${C}]${G} Upload     : ${Y}$ul_val"
	echo -e "  ${C}-------------------------------------------------------${W}"
	echo -e "   ${C}[${Y} » ${C}]${M} Browsing Quality  : ${b_qual}"
	echo -e "   ${C}[${Y} » ${C}]${M} Gaming Quality    : ${g_qual}"
	echo -e "   ${C}[${Y} » ${C}]${M} Streaming Quality : ${s_qual}"
	echo -e "   ${C}[${Y} » ${C}]${M} Video Call Quality: ${v_qual}"
	echo -e "  ${C}=======================================================${W}"

    # İşimiz bitince ham veriyi siliyoruz
	rm -f "$RAW_FILE"

	# Sonuçları kaydetme aşaması
	read -p " $(echo -e " ${C}[${Y}?${C}]${M} Do you want to save the results to a file? (Y/n): ${Y}")" save_choice

	if [[ -z $save_choice || $save_choice == Y || $save_choice == y ]]; then
		log_file="speedtest_result_$(date +%Y%m%d_%H%M%S).txt"
		mv "$RESULT_FILE" ~/"$log_file"
		echo -e "\n  ${C}[${G}✓${C}]${G} Saved successfully as:\n\n  ${C}[${G}i${C}] ${Y}~/$log_file"
	else
		rm -f "$RESULT_FILE"
		echo -e "\n  ${C}[${R}x${C}]${R} Results deleted."
	fi
}

spin () {
    local pid=$!
    local delay=0.10
    local spinner=(
    "${B}■■■■■■■"
    "${G}█${Y}■■■■■■"
    "${Y}■${G}█${Y}■■■■■"
    "${Y}■■${G}█${Y}■■■■"
    "${Y}■■■${G}█${Y}■■■"
    "${Y}■■■■${G}█${Y}■■"
    "${Y}■■■■■${G}█${Y}■"
    "${Y}■■■■■■${G}█"
    "${B}■■■■■■■"
    "${Y}■■■■■■${G}█"
    "${Y}■■■■■${G}█${Y}■"
    "${Y}■■■■${G}█${Y}■■"
    "${Y}■■■${G}█${Y}■■■"
    "${Y}■■${G}█${Y}■■■■"
    "${Y}■${G}█${Y}■■■■■"
    "${G}█${Y}■■■■■■"
	)

    local msg_loading="$1"
    local msg_done="$2"
    local msg_fail="${3:-${W}⟫${R} Failed!}" # 3. parametre girilmezse varsayılan hata mesajı

    echo -e ""

    while kill -0 $pid 2>/dev/null; do
      for i in "${spinner[@]}"; do
        echo -ne "\r  $msg_loading ${C}【$i${C}】\033[K";
        sleep $delay 2>/dev/null
        # İşlem for döngüsü içindeyken bittiyse anında çık
        kill -0 $pid 2>/dev/null || break
      done
    done

    # İşlemin çıkış kodunu (0: Başarılı, >0: Hata) yakala
    wait $pid 2>/dev/null
    local exit_code=$?

    if [ $exit_code -eq 0 ]; then
        echo -e "\r  $msg_loading \033[K$msg_done"
        return 0
    else
        echo -e "\r  $msg_loading \033[K$msg_fail"
        return $exit_code
    fi
}

while true; do
clear;echo -e "
${C} #######${Y} ##################${C} #######${Y} ####################
${C}    #    #####  #####          #     ####   ####  #
${C}    #    #    # #    #         #    #    # #    # #
${C}    #    #    # #    #  #####  #    #    # #    # #
${C}    #    #    # #####          #    #    # #    # #
${C}    #    #    # #   #          #    #    # #    # #
${C}    #    #####  #    #         #     ####   ####  ######
${Y} ###################[›${G} TheDarkRoot ${Y}‹]###################
${C} =======================================================
${C} ┌⊸⟜┬───⊸ [${M} TheDarkRoot Repositories: ${C}]
${C} │  ├─┬─⊸ [${Y}~1${R} Hasher${C}]
${C} │  │ └─⊸ [${Y} »${G} This is a Hash Cracker.${C}]
${C} │  ├─┬─⊸ [${Y}~2${R} Hashgen${C}]
${C} │  │ └─⊸ [${Y} »${G} Generate more 39 type hash.${C}]
${C} │  ├─┬─⊸ [${Y}~3${R} Tertext${C}]
${C} │  │ └─⊸ [${Y} »${G} Program for creating words from letters.${C}]
${C} │  ├─┬─⊸ [${Y}~4${R} UserID${C}]
${C} │  │ └─⊸ [${Y} »${G} Search usernames on social media.${C}]
${C} │  └─┬─⊸ [${Y}~X${R} X${C}]
${C} │    └─⊸ [${Y} »${G} TheDarkRoot All-in-One Repositories.${C}]
${C} └⊸⟜┬───⊸ [${M} Termux Settings: ${C}]
${C}    ├─┬─⊸ [${Y}~N${R} Network${C}]
${C}    │ └─⊸ [${Y} »${G} Test your network connection.${C}]
${C}    ├─┬─⊸ [${Y}~U${R} Update${C}]
${C}    │ └─⊸ [${Y} »${G} Termux update.${C}]
${C}    ├─┬─⊸ [${Y}~P${R} ParrotOS-T${C}]
${C}    │ └─⊸ [${Y} »${G} Parrot OS theme for Termux.${C}]
${C}    ├─┬─⊸ [${Y}~T${R} TheDarkRoot-T${C}]
${C}    │ └─⊸ [${Y} »${G} TheDarkRoot theme for Termux.${C}]
${C}    └─┬─⊸ [${Y}~Q${R} Exit${C}]
${C}      └─⊸ [${Y} »${G} Tdr-Tool exit.${C}]\n"

read -p " $(echo -e " ${C}[${Y}~${C}]${M} Program Number: ${Y}")" pn

	if [[ $pn == U || $pn == u ]]; then

	ping -c 1 8.8.8.8 &> /dev/null
	if [ $? -eq 0 ]; then
		status="${W}⟫${G} ONLINE"
		is_online=true
	else
		status="${W}⟫${R} OFFLINE"
		is_online=false
	fi

	( sleep 1.5 ) &> /dev/null & spin "${C}[${Y}i${C}]${G} Network control..." "$status"

	if [ "$is_online" = true ]; then
		run_update

		echo -e "\n ${C} [${Y}!${C}]${G} Update completed!\n"

		read -p " $(echo -e " ${C}[${Y}?${C}]${M} Want to run an network speed test? (Y/n): ${Y}")" st_choice_aio

		if [[ -z $st_choice_aio || $st_choice_aio == Y || $st_choice_aio == y ]]; then
			run_speedtest
		else
			echo -e "\n  ${C}[${Y}i${C}]${G} Speedtest skipped."
		fi

	else
		echo -e "\n ${C} [${R}!${C}]${R} Check your network connection."
	fi

	elif [[ $pn == UT || $pn == ut ]]; then
	echo -e "\n ${C} [${Y}i${C}]${G} Tdr-Tool: Fast updating program...";
	(
	 cd ~/ && curl -sLf "$Raw/Tdr-Tool/master/Tdr-Tool.sh?t=$(date +%s)" -o Tdr-Tool_temp.sh;
	 rm -rf  Tdr-Tool.sh && mv Tdr-Tool_temp.sh Tdr-Tool.sh && chmod +x Tdr-Tool.sh; 
	) &> ~/.TheDarkRootTool_debug.log & spin "${C}[${Y}↓${C}]${G} Tdr-Tool Updating...${Y}" " ${W}⟫${G} Complete."

	elif [[ $pn == N || $pn == n ]]; then

	ping -c 1 8.8.8.8 &> /dev/null
	if [ $? -eq 0 ]; then
		status="${W}⟫${G} ONLINE"
		is_online=true
	else
		status="${W}⟫${R} OFFLINE"
		is_online=false
	fi

	( sleep 1.5 ) &> /dev/null & spin "${C}[${Y}i${C}]${G} Network control..." "$status"

	if [ "$is_online" = true ]; then
		echo -e ""
		read -p " $(echo -e " ${C}[${Y}?${C}]${M} Want to run an network speed test? (Y/n): ${Y}")" st_choice

		if [[ -z $st_choice || $st_choice == Y || $st_choice == y ]]; then
			run_speedtest
		else
			echo -e "\n  ${C}[${Y}i${C}]${G} Speedtest skipped."
		fi
	fi

	elif [[ $pn == P || $pn == p ]]; then
	echo -e "\n ${C} [${Y}i${C}]${G} ParrotOS-T: Parrot OS theme for Termux.";
	(
	  cd $Etc && curl -sLf "$Raw/FileStore/master/Software%20Files/ParrotOS.trmx?t=$(date +%s)" -o bash.bashrc.tmp;
	  rm -rf bash.bashrc && mv bash.bashrc.tmp bash.bashrc;
	  cd ~/.termux && curl -sLf "$Raw/FileStore/master/Software%20Files/Terkey.trmx?t=$(date +%s)" -o termux.properties.tmp;
	  rm -rf termux.properties && mv termux.properties.tmp termux.properties;
	  cd ~/ && $Reload;
	) &> ~/.TheDarkRoot_debug.log & spin "${C}[${Y}↓${C}]${G} Downloading ParrotOS-T..." " ${W}⟫${G} Complete."

	elif [[ $pn == T || $pn == t ]]; then
	echo -e "\n ${C} [${Y}i${C}]${G} TheDarkRoot-T: TheDarkRoot theme for Termux.";
	(
	  cd $Etc && curl -sLf "$Raw/FileStore/master/Software%20Files/TheDarkRoot.trmx?t=$(date +%s)" -o bash.bashrc.tmp;
	  rm -rf bash.bashrc && mv bash.bashrc.tmp bash.bashrc;
	  cd ~/.termux && curl -sLf "$Raw/FileStore/master/Software%20Files/Terkey.trmx?t=$(date +%s)" -o termux.properties.tmp;
	  rm -rf termux.properties && mv termux.properties.tmp termux.properties;
	  cd ~/ && $Reload;
	) &> ~/.TheDarkRoot_debug.log & spin "${C}[${Y}↓${C}]${G} Downloading TheDarkRoot-T..." " ${W}⟫${G} Complete."

	elif [[ $pn == X || $pn == x ]]; then
	echo -e "\n ${C} [${Y}i${C}]${G} X: TheDarkRoot All-in-One Repositories.";
	(
	  install_tool "Hasher"
	  install_tool "Hashgen"
	  install_tool "Tertext"
	  install_tool "UserID"
	  cd ~/ && curl -sLf "$Raw/Tdr-Tool/master/Tdr-Tool.sh?t=$(date +%s)" -o Tdr-Tool_temp.sh;
	  rm -rf  Tdr-Tool.sh && mv Tdr-Tool_temp.sh Tdr-Tool.sh && chmod +x Tdr-Tool.sh && $Reload;
	) &> ~/.TheDarkRoot_debug.log & spin "${C}[${Y}↓${C}]${G} Downloading X..." " ${W}⟫${G} Complete."

	elif [[ $pn == 1 || $pn == 01 ]]; then
	echo -e "\n ${C} [${Y}i${C}]${G} Hasher: This is a Hash Cracker.";
	( install_tool "Hasher" && $Reload; ) &> ~/.TheDarkRoot_debug.log & spin "${C}[${Y}↓${C}]${G} Downloading Hasher..." " ${W}⟫${G} Complete."

	elif [[ $pn == 2 || $pn == 02 ]]; then
	echo -e "\n ${C} [${Y}i${C}]${G} Hashgen: Generate more 39 type hash.";
	( install_tool "Hashgen" && $Reload; ) &> ~/.TheDarkRoot_debug.log & spin "${C}[${Y}↓${C}]${G} Downloading Hashgen..." " ${W}⟫${G} Complete."

	elif [[ $pn == 3 || $pn == 03 ]]; then
	echo -e "\n ${C} [${Y}i${C}]${G} Tertext: Program for creating words from letters.";
	( install_tool "Tertext" && $Reload; ) &> ~/.TheDarkRoot_debug.log & spin "${C}[${Y}↓${C}]${G} Downloading Tertext..." " ${W}⟫${G} Complete."

	elif [[ $pn == 4 || $pn == 04 ]]; then
	echo -e "\n ${C} [${Y}i${C}]${G} UserID: Search usernames on social media.";
	( install_tool "UserID" && $Reload; ) &> ~/.TheDarkRoot_debug.log & spin "${C}[${Y}↓${C}]${G} Downloading UserID..." " ${W}⟫${G} Complete."

	elif [[ $pn == Q || $pn == q ]]; then
	echo -e "\n ${C} [${Y}»${C}]${R} Good Bye...\n";
	sleep 0;exit;

	else
	echo -e "\n  ${Y}[${R}⦸${Y}]${R} Invalid Action."	
	sleep 1.5

    fi

	if [[ $pn != Q && $pn != q && $pn != "" ]]; then
		if [[ $pn =~ ^(U|u|UT|ut|P|p|T|t|X|x|[1-4]|0[1-4]|N|n)$ ]]; then

			read -n 1 -s -p " $(echo -e "\n  ${C}[${Y}~${C}]${M} Press any key to return to main menu...${Y}")"

			if [[ $pn == U || $pn == u || $pn == UT || $pn == ut || $pn == X || $pn == x ]]; then
				exec bash ~/Tdr-Tool.sh
			fi
		fi
	fi
done