#!/usr/bin/env bash
# -*- coding: utf-8 -*-

# Renk Tanımlamaları
B='\033[34;1m'  # Mavi
Y='\033[33;1m'  # Sarı
G='\033[32;1m'  # Yeşil
W='\033[0;1m'   # Beyaz
R='\033[31;1m'  # Kırmızı
C='\033[36;1m'  # Turkuaz
M='\033[35;1m'  # Magenta

# 1. Ortam Kontrolü ve Dinamik Yol Tanımlamaları (Çakışmalar Engellendi)
if [ -d "/data/data/com.termux/files/home" ]; then
    IS_TERMUX=true
    Etc="$PREFIX/etc"
    Termux="$HOME/.termux"
    Reload="termux-reload-settings"
    PKG_MAN="pkg"
else
    IS_TERMUX=false
    Etc="/etc"
    Termux="$HOME" 
    Reload="source $HOME/.bashrc 2>/dev/null || source $HOME/.zshrc 2>/dev/null"
    PKG_MAN="apt"
fi

# Ortak Klasör ve Link Yapısı
Tool="$HOME/Tdr-Tool"
Backup="$Tool/.Backup"
Network="$Tool/.NetworkLog"
Github="https://github.com"
TheDarkRoot="$Github/TheDarkRoot"
Raw="https://raw.githubusercontent.com/TheDarkRoot"

# 2. Termux Depolama İzni Kontrolü
if [ "$IS_TERMUX" = true ]; then
    if [ ! -d "$HOME/storage" ]; then
        termux-setup-storage
        until [ -d "$HOME/storage" ]; do sleep 1; done
        $Reload
    fi
fi

# 3. Gerekli Tüm Klasörlerin Oluşturulması
setup_folders=(
    "$Tool"
    "$Termux"
    "$Backup"
    "$Network"
)

for dir in "${setup_folders[@]}"; do
    if [ ! -d "$dir" ]; then
        mkdir -p "$dir"
    fi
done

# Parametre Kontrolü (-i parametresi infoyu basar ve çıkar)
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
${G} |${Y} [${C}=${Y}]${W} Name     ${C}:${W} Tdr-Tool                             ${G}|
${G} |${Y} [${C}=${Y}]${W} Code     ${C}:${W} Shell                                ${G}|
${G} |${Y} [${C}=${Y}]${W} Version  ${C}:${W} v1.2.7 (Alpha)                       ${G}|
${G} |${Y} [${C}=${Y}]${W} Author   ${C}:${W} Tdr-Tool                             ${G}|
${G} |${Y} [${C}=${Y}]${W} Github   ${C}:${W} https://github.com/TheDarkRoot       ${G}|
${G} |${Y} [${C}=${Y}]${W} Telegram ${C}:${W} @TheDarkRoot (t.me/TheDarkRoot)      ${G}|
${G} 0{===================================================}0\n"
        exit 0
        ;;
    *)
        ;;
esac

# İlerleme Çubuğu Fonksiyonu (PID takibi güvenli hale getirildi)
spin () {
    local pid="$1"
    local msg_loading="$2"
    local msg_done="$3"
    local msg_fail="${4:-${W}⟫${R} Failed!}"
    local delay=0.10
    local spinner=(
        "${B}■■■■■■■" "${G}█${Y}■■■■■■" "${Y}■${G}█${Y}■■■■■" "${Y}■■${G}█${Y}■■■■" 
        "${Y}■■■${G}█${Y}■■■" "${Y}■■■■${G}█${Y}■■" "${Y}■■■■■${G}█${Y}■" "${Y}■■■■■■${G}█" 
        "${B}■■■■■ำ■" "${Y}■■■■■■${G}█" "${Y}■■■■■${G}█${Y}■" "${Y}■■■■${G}█${Y}■■" 
        "${Y}■■■${G}█${Y}■■■" "${Y}■■${G}█${Y}■■■■" "${Y}■${G}█${Y}■■■■■" "${G}█${Y}■■■■■■"
    )

    echo -ne ""
    while kill -0 "$pid" 2>/dev/null; do
      for i in "${spinner[@]}"; do
        echo -ne "\r  $msg_loading ${C}【$i${C}】\033[K"
        sleep $delay 2>/dev/null
        kill -0 "$pid" 2>/dev/null || break
      done
    done

    wait "$pid" 2>/dev/null
    local exit_code=$?

    if [ $exit_code -eq 0 ]; then
        echo -e "\r  $msg_loading \033[K$msg_done"
        return 0
    else
        echo -e "\r  $msg_loading \033[K$msg_fail"
        return $exit_code
    fi
}

# Ağ Kontrol Fonksiyonu
check_network() {
    ping -c 1 8.8.8.8 &> /dev/null
    if [ $? -eq 0 ]; then
        status="${W}⟫${G} ONLINE"
        is_online=true
    else
        status="${W}⟫${R} OFFLINE"
        is_online=false
    fi

    ( sleep 1.5 ) &> /dev/null & 
    spin $! "${C}[${Y}i${C}]${G} Network control..." "$status"
}

# Bağımlılıkları kontrol eden fonksiyon (sudo eklendi)
check_dependencies() {
    local deps=("git" "curl" "awk" "bc" "grep")
    local missing=()

    for cmd in "${deps[@]}"; do
        if ! command -v "$cmd" &> /dev/null; then
            missing+=("$cmd")
        fi
    done

    if [ ${#missing[@]} -gt 0 ]; then
        echo -e "\n ${C}[${Y}i${C}]${G} Missing dependencies detected: ${missing[*]}"
        echo -e "\n ${C}[${Y}i${C}]${G} Installing automatically, please wait..."

        if [ "$IS_TERMUX" = true ]; then
            pkg install -y "${missing[@]}" &>> ~/.TheDarkRoot_debug.log
        else
            sudo apt-get update -y &>/dev/null
            sudo apt-get install -y "${missing[@]}" &>> ~/.TheDarkRoot_debug.log
        fi

        echo -e "\n\n  ${C}[${G}✓${C}]${G} Setup complete. Restarting...\n"
        sleep 2
        exec bash "$0"
    fi
}

check_dependencies 

# Log Yönetimi
manage_logs() {
    local log_file="$HOME/.TheDarkRoot_debug.log"
    if [ -f "$log_file" ] && [ $(du -k "$log_file" | cut -f1) -gt 1024 ]; then
        echo "$(date): Log rotated." > "$log_file"
    fi
}

manage_logs

# Paket yükleme fonksiyonu (Dinamik sorgulama eklendi)
install_packages() {
    local manager="$1"
    shift
    local missing_pkgs=()

    if [ "$IS_TERMUX" = false ] && [ "$manager" = "pkg" ]; then
        manager="apt"
    fi

    for pkg in "$@"; do
        case "$manager" in
            pkg|apt) 
                if ! dpkg -s "$pkg" &> /dev/null; then missing_pkgs+=("$pkg"); fi 
                ;;
            pip) 
                if ! python3 -c "import sys, importlib.util; sys.exit(0 if importlib.util.find_spec('${pkg//-/_}') else 1)" &> /dev/null; then 
                    missing_pkgs+=("$pkg")
                fi
                ;;
            npm) 
                if ! npm list -g "$pkg" &> /dev/null; then missing_pkgs+=("$pkg"); fi 
                ;;
            gem) 
                if ! gem list -i "^$pkg$" &> /dev/null; then missing_pkgs+=("$pkg"); fi 
                ;;
        esac
    done

    if [ ${#missing_pkgs[@]} -gt 0 ]; then
        echo -e "\n ${C}[${Y}i${C}]${G} Installing: ${missing_pkgs[*]}"
        case "$manager" in
            pkg) pkg install -y "${missing_pkgs[@]}" ;;
            apt) sudo apt-get install -y "${missing_pkgs[@]}" ;; 
            pip) python3 -m pip install --upgrade --break-system-packages "${missing_pkgs[@]}" ;;
            npm) sudo npm install -g "${missing_pkgs[@]}" ;;
            gem) 
                for gem_pkg in "${missing_pkgs[@]}"; do
                    sudo gem install "$gem_pkg"
                done
                ;;
        esac
    else
        echo -e "\n ${C}[${Y}i${C}]${G} All packages are already installed."
    fi
}

# Araç Kurma Fonksiyonu
install_tool() {
    local tool_name="$1"
    local target_dir="$Tool/$tool_name"
    local temp_dir="$Tool/${tool_name}_temp"
    local backup_target="$Backup/${tool_name}_$(date +%Y%m%d).bckp"

    if ! ping -c 1 8.8.8.8 &> /dev/null; then
        echo -e "\n  ${C}[${R}!${C}]${R} Cut! Please check your network connection."
        return 1
    fi

    rm -rf "$temp_dir"

    if git clone --quiet "$TheDarkRoot/$tool_name.git" "$temp_dir" &> /dev/null; then
        if [ -d "$target_dir" ]; then
            mv "$target_dir" "$Tool/${tool_name}.bckp"
            [ -d "$backup_target" ] && rm -rf "$backup_target"
            mv "$Tool/${tool_name}.bckp" "$backup_target"
        fi

        mv "$temp_dir" "$target_dir"
        chmod -R +x "$target_dir"
        return 0
    else
        echo -e "\n  ${C}[${R}!${C}]${R} Error: Download failed."
        rm -rf "$temp_dir"
        return 1
    fi
}

# Tema Kurma Fonksiyonu (Kali Korumalı)
install_theme() {
    local theme_name="$1"

    if [ "$IS_TERMUX" = false ]; then
        echo -e "\n  ${Y}[${R}⦸${Y}]${R} Hata: Bu tema yapısı sadece Termux ortamı için tasarlanmıştır!"
        sleep 2
        return 1
    fi

    case "$theme_name" in
        "Parrot")
            echo -e "\n ${C} [${Y}i${C}]${G} ParrotOS-T: Parrot OS theme for Termux."
            backup_files 

            (
             if curl -sLf "$Raw/FileStore/master/Software%20Files/ParrotOS.trmx?t=$(date +%s)" -o "$Etc/bash.bashrc" && \
                curl -sLf "$Raw/FileStore/master/Software%20Files/Terkey.trmx?t=$(date +%s)" -o "$Termux/termux.properties"; then
                 $Reload
             else
                 restore_files 
             fi
            ) &>> ~/.TheDarkRoot_debug.log & 
            spin $! "${C}[${Y}↓${C}]${G} Downloading ParrotOS-T..." " ${W}⟫${G} Complete."
            ;;

        "TheDarkRoot")
            echo -e "\n ${C} [${Y}i${C}]${G} TheDarkRoot-T: TheDarkRoot theme for Termux."
            backup_files 

            (
             if curl -sLf "$Raw/FileStore/master/Software%20Files/TheDarkRoot.trmx?t=$(date +%s)" -o "$Etc/bash.bashrc" && \
                curl -sLf "$Raw/FileStore/master/Software%20Files/Terkey.trmx?t=$(date +%s)" -o "$Termux/termux.properties"; then
                 $Reload
             else
                 restore_files 
             fi
            ) &>> ~/.TheDarkRoot_debug.log & 
            spin $! "${C}[${Y}↓${C}]${G} Downloading TheDarkRoot-T..." " ${W}⟫${G} Complete."
            ;;
            
        *)
            echo -e "\n  ${Y}[${R}⦸${Y}]${R} Hata: Geçersiz tema adı!"
            return 1
            ;;
    esac
}

# Yedekleme
backup_files() {
    [ -f "$Etc/bash.bashrc" ] && cp "$Etc/bash.bashrc" "$Etc/bash.bashrc.bckp"
    [ -f "$Termux/termux.properties" ] && cp "$Termux/termux.properties" "$Termux/termux.properties.bckp"
    echo -e "\n ${C} [${Y}i${C}]${G} Backup completed."
}

# Geri Yükleme
restore_files() {
    if [ -f "$Etc/bash.bashrc.bckp" ]; then
        mv "$Etc/bash.bashrc.bckp" "$Etc/bash.bashrc"
    fi
    if [ -f "$Termux/termux.properties.bckp" ]; then
        mv "$Termux/termux.properties.bckp" "$Termux/termux.properties"
    fi
    echo -e "\n ${C} [${R}!${C}]${R} Error: Backup restored successfully."
}

# Kendini Güncelleme
update_self() {
    (
     cd ~/ && curl -sLf "$Raw/Tdr-Tool/master/Tdr-Tool.sh?t=$(date +%s)" -o Tdr-Tool_temp.sh;
     rm -rf Tdr-Tool.sh && mv Tdr-Tool_temp.sh Tdr-Tool.sh && chmod +x Tdr-Tool.sh;
    ) &>> ~/.TheDarkRootTool_debug.log & 
    spin $! "${C}[${Y}↓${C}]${G} Tdr-Tool Updating...${Y}" " ${W}⟫${G} Complete."
}

# Sistem ve Paket Güncelleme (Kali Uyumluluğu Artırıldı)
run_update () {
    echo -e "\n ${C} [${Y}i${C}]${G} Starting the update..."
    
    if [ "$IS_TERMUX" = true ]; then
        (
         export DEBIAN_FRONTEND=noninteractive
         pkg update -y && pkg upgrade -y
         $Reload
        ) &>> ~/.TermuxUpdate_debug.log & 
        spin $! "${C}[${Y}↓${C}]${G} Updating System..." " ${W}⟫${G} Complete."
        
        (
          install_packages pkg termux-tools coreutils binutils git curl wget sed grep gawk bc jq ncurses-utils python ruby php clang make openssh openssl zip unzip tar proot crunch neofetch nano vim cmatrix sl tmate zsh bash tor privoxy play-audio mpv cowsay figlet toilet nodejs
          $Reload
        ) &>> ~/.TermuxPackages_debug.log & 
        spin $! "${C}[${Y}↓${C}]${G} Packages Installing..." " ${W}⟫${G} Complete."
    else
        (
         sudo apt-get update -y && sudo apt-get upgrade -y
        ) &>> ~/.KaliUpdate_debug.log & 
        spin $! "${C}[${Y}↓${C}]${G} Updating Kali Linux..." " ${W}⟫${G} Complete."
        
        (
          install_packages apt coreutils binutils git curl wget sed grep gawk bc jq ncurses-utils python3 python3-pip python3-setuptools python3-wheel ruby php clang make openssh-client openssl zip unzip tar crunch neofetch nano vim cmatrix sl tmate zsh bash tor privoxy cowsay figlet toilet nodejs
        ) &>> ~/.KaliPackages_debug.log & 
        spin $! "${C}[${Y}↓${C}]${G} System Packages Installing..." " ${W}⟫${G} Complete."
    fi

    # Dil ve Ekosistem Araçları Kurulumu
    (
      install_packages pip setuptools wheel bs4 requests mechanize passlib progressbar2 pillow termcolor speedtest-cli
      install_packages npm readline-sync speed-test
      install_packages gem lolcat
      $Reload
    ) &>> ~/.TheDarkRoot_debug.log & 
    spin $! "${C}[${Y}↓${C}]${G} Tools Installing..." " ${W}⟫${G} Complete."
    
    update_self  
}

# Hız Testi Fonksiyonu
run_speedtest () {
    local dependencies=("python3" "awk" "bc" "curl")
    for cmd in "${dependencies[@]}"; do
        if ! command -v "$cmd" &> /dev/null; then
            echo -e "\n  ${C}[${R}!${C}]${R} Error: '$cmd' package missing!"
            return 1
        fi
    done

    local RAW_FILE=$(mktemp)
    local RESULT_FILE=$(mktemp)

    (
        if command -v speedtest-cli &> /dev/null; then
            speedtest-cli > "$RAW_FILE" 2>&1
        else
            [ ! -f "$Tool/speedtest.py" ] && curl -sL https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py -o "$Tool/speedtest.py"
            python3 -W ignore "$Tool/speedtest.py" > "$RAW_FILE" 2>&1
        fi
    ) &
    
    spin $! "${C}[${Y}↓${C}]${G} Testing network speed..." " ${W}⟫${G} Complete." " ${W}⟫${R} Failed!"

    if [ ! -s "$RAW_FILE" ] || ! grep -q "Download:" "$RAW_FILE"; then
        echo -e "\n  ${C}[${R}!${C}]${R} Cut! Please check your network connection."
        rm -f "$RAW_FILE" "$RESULT_FILE"
        return 1
    fi

    my_ip=$(grep -oE "Testing from .* \([0-9.]+\)" "$RAW_FILE" | grep -oE "[0-9.]+" | head -n 1)
    provider=$(grep -oE "Testing from .* \(" "$RAW_FILE" | sed 's/Testing from //' | sed 's/ ($//' | sed 's/ (//')
    server_info=$(grep "Hosted by" "$RAW_FILE" | sed 's/Hosted by //' | cut -d '[' -f1 | sed 's/ *$//')
    ping_val=$(grep -oE "([0-9.]+ ms|\[[0-9.]+ ms\])" "$RAW_FILE" | head -n 1 | sed 's/\[//g; s/\]//g')
    dl_val=$(grep "Download:" "$RAW_FILE" | sed 's/Download: //')
    ul_val=$(grep "Upload:" "$RAW_FILE" | sed 's/Upload: //')

    dl_num=$(echo "$dl_val" | awk '{print $1}')
    ul_num=$(echo "$ul_val" | awk '{print $1}')
    ping_num=$(echo "$ping_val" | awk '{print $1}')

    [[ ! "$dl_num" =~ ^[0-9.]+$ ]] && dl_num=0
    [[ ! "$ul_num" =~ ^[0-9.]+$ ]] && ul_num=0
    [[ ! "$ping_num" =~ ^[0-9.]+$ ]] && ping_num=0

    b_qual="${R} Poor" && g_qual="${R} Poor" && s_qual="${R} Poor" && v_qual="${R} Poor"
    if (( $(echo "$dl_num >= 15" | bc -l) )); then b_qual="${G} Great"; elif (( $(echo "$dl_num >= 5" | bc -l) )); then b_qual="${Y} Good"; fi
    if (( $(echo "$ping_num <= 30 && $ping_num > 0" | bc -l) && $(echo "$ul_num >= 5" | bc -l) )); then g_qual="${G} Great"; elif (( $(echo "$ping_num <= 60" | bc -l) )); then g_qual="${Y} Good"; fi
    if (( $(echo "$dl_num >= 25" | bc -l) )); then s_qual="${G} Great"; elif (( $(echo "$dl_num >= 10" | bc -l) )); then s_qual="${Y} Good"; fi
    if (( $(echo "$ul_num >= 8" | bc -l) && $(echo "$ping_num <= 40" | bc -l) )); then v_qual="${G} Great"; elif (( $(echo "$ul_num >= 3" | bc -l) )); then v_qual="${Y} Good"; fi

    echo -e "IP Address: $my_ip\nProvider: $provider\nServer: $server_info\nPing: $ping_val\nDownload: $dl_val\nUpload: $ul_val" > "$RESULT_FILE"
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

    rm -f "$RAW_FILE"
    read -p " $(echo -e " ${C}[${Y}?${C}]${M} Do you want to save the results to a file? (Y/n): ${Y}")" save_choice
    if [[ -z ${save_choice,,} || ${save_choice,,} == y* ]]; then
        log_file="NetworkLog.$(date +%Y%m%d_%H%M%S).txt"
        mv "$RESULT_FILE" "$Network/$log_file"
        echo -e "\n  ${C}[${G}✓${C}]${G} Saved successfully:\n  ${C}[${G}i${C}] ${Y}~/$log_file"
    else
        rm -f "$RESULT_FILE"
        echo -e "\n  ${C}[${R}x${C}]${R} Results deleted."
    fi
}

# ANA DÖNGÜ (MENU)
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
${C} └⊸⟜┬───⊸ [${M} Termux / Linux Settings: ${C}]
${C}    ├─┬─⊸ [${Y}~N${R} Network${C}]
${C}    │ └─⊸ [${Y} »${G} Test your network connection.${C}]
${C}    ├─┬─⊸ [${Y}~U${R} Update${C}]
${C}    │ └─⊸ [${Y} »${G} System & Tool update.${C}]
${C}    ├─┬─⊸ [${Y}~P${R} ParrotOS-T${C}]
${C}    │ └─⊸ [${Y} »${G} Parrot OS theme (Termux Only).${C}]
${C}    ├─┬─⊸ [${Y}~T${R} TheDarkRoot-T${C}]
${C}    │ └─⊸ [${Y} »${G} TheDarkRoot theme (Termux Only).${C}]
${C}    └─┬─⊸ [${Y}~Q${R} Exit${C}]
${C}      └─⊸ [${Y} »${G} Tdr-Tool exit.${C}]\n"

read -p " $(echo -e " ${C}[${Y}~${C}]${M} Program Number: ${Y}")" pn
pn_lower="${pn,,}"

# Girişteki sol sıfırları temizleme (Örn: 01 -> 1)
pn_clean="${pn_lower#0}"

case "$pn_clean" in
    u)
        check_network 
        if [ "$is_online" = true ]; then
            run_update
            echo -e "\n ${C} [${Y}!${C}]${G} Update completed!\n"
            read -p " $(echo -e " ${C}[${Y}?${C}]${M} Want to run a network speed test? (Y/n): ${Y}")" st_choice_aio
            if [[ -z $st_choice_aio || "${st_choice_aio,,}" == y* ]]; then
                run_speedtest
            else
                echo -e "\n  ${C}[${Y}i${C}]${G} Speedtest skipped."
            fi
        else
            echo -e "\n ${C} [${R}!${C}]${R} Check your network connection."
        fi
        ;;

    ut)
        echo -e "\n ${C} [${Y}i${C}]${G} Tdr-Tool: Fast updating program..."
        update_self  
        ;;

    n)
        check_network 
        if [ "$is_online" = true ]; then
            echo -e ""
            read -p " $(echo -e " ${C}[${Y}?${C}]${M} Want to run a network speed test? (Y/n): ${Y}")" st_choice
            if [[ -z $st_choice || "${st_choice,,}" == "y" ]]; then
                run_speedtest
            else
                echo -e "\n  ${C}[${Y}i${C}]${G} Speedtest skipped."
            fi
        fi
        ;;

    p)
        install_theme "Parrot"
        ;;

    t)
        install_theme "TheDarkRoot"
        ;;

    x)
        check_network
        if [ "$is_online" = true ]; then
            echo -e "\n ${C} [${Y}i${C}]${G} X: TheDarkRoot All-in-One Repositories."
            (
                install_tool "Hasher"
                install_tool "Hashgen"
                install_tool "Tertext"
                install_tool "UserID"
                update_self 
            ) &>> ~/.TheDarkRoot_debug.log & 
            spin $! "${C}[${Y}↓${C}]${G} Downloading X..." " ${W}⟫${G} Complete."
        else
            echo -e "\n  ${C}[${R}!${C}]${R} Cut! Please check your network connection."
        fi
        ;;

    1)
        echo -e "\n ${C} [${Y}i${C}]${G} Hasher: This is a Hash Cracker."
        ( install_tool "Hasher" && $Reload; ) &>> ~/.TheDarkRoot_debug.log & 
        spin $! "${C}[${Y}↓${C}]${G} Downloading Hasher..." " ${W}⟫${G} Complete."
        ;;

    2)
        echo -e "\n ${C} [${Y}i${C}]${G} Hashgen: Generate more 39 type hash."
        ( install_tool "Hashgen" && $Reload; ) &>> ~/.TheDarkRoot_debug.log & 
        spin $! "${C}[${Y}↓${C}]${G} Downloading Hashgen..." " ${W}⟫${G} Complete."
        ;;

    3)
        echo -e "\n ${C} [${Y}i${C}]${G} Tertext: Program for creating words from letters."
        ( install_tool "Tertext" && $Reload; ) &>> ~/.TheDarkRoot_debug.log & 
        spin $! "${C}[${Y}↓${C}]${G} Downloading Tertext..." " ${W}⟫${G} Complete."
        ;;

    4)
        echo -e "\n ${C} [${Y}i${C}]${G} UserID: Search usernames on social media."
        ( install_tool "UserID" && $Reload; ) &>> ~/.TheDarkRoot_debug.log & 
        spin $! "${C}[${Y}↓${C}]${G} Downloading UserID..." " ${W}⟫${G} Complete."
        ;;

    q)
        echo -e "\n ${C} [${Y}»${C}]${R} Good Bye...\n"
        exit 0
        ;;

    *)
        echo -e "\n  ${Y}[${R}⦸${Y}]${R} Invalid Action."    
        sleep 1.5
        ;;
esac

# Menüye Dönüş Bekleme Bloğu
if [[ "$pn_clean" != "q" && "$pn_clean" != "" && "$pn_clean" =~ ^(u|ut|p|t|x|1|2|3|4|n)$ ]]; then
    read -n 1 -s -p " $(echo -e "\n  ${C}[${Y}~${C}]${M} Press any key to return to main menu...${Y}")"
    if [[ "$pn_clean" =~ ^(u|ut|x)$ ]]; then
        echo -e "\n\n  ${C}[${Y}i${C}]${G} Restarting Tdr-Tool..."
        sleep 2
        exec bash "$0"
    fi
fi
done