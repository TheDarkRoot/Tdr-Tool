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

# $HOME/   - /data/data/com.termux/files/home/
# $PREFIX/ - /data/data/com.termux/files/usr/etc/
Etc="$PREFIX/etc"
Termux="$HOME/.termux"
Tool="$HOME/Tdr-Tool"
Backup="$HOME/Tdr-Tool/.Backup"
Network="$HOME/Tdr-Tool/.NetworkLog"
Github="https://github.com"
TheDarkRoot="https://github.com/TheDarkRoot"
Raw="https://raw.githubusercontent.com/TheDarkRoot"
Reload="termux-reload-settings"

# 1. Termux Depolama İzni Kontrolü
if [ ! -d "$HOME/storage" ]; then
    termux-setup-storage
    sleep 5 && $Reload
fi

# 2. Gerekli Tüm Klasörlerin Oluşturulması
# İleride yeni bir klasör eklemek istersen sadece bu listeye yolunu yazman yeterli!
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
        # Eğer parametre yoksa veya tanınmıyorsa menüye devam et
        ;;
esac

check_network() {
    ping -c 1 8.8.8.8 &> /dev/null
    if [ $? -eq 0 ]; then
        status="${W}⟫${G} ONLINE"
        is_online=true
    else
        status="${W}⟫${R} OFFLINE"
        is_online=false
    fi

    ( sleep 1.5 ) &> /dev/null & spin "${C}[${Y}i${C}]${G} Network control..." "$status"
}

install_packages() {
    local manager="$1"
    shift
    local missing_pkgs=()

    # Adım 1: Paket yöneticisine göre eksik paketleri tespit et
	for pkg in "$@"; do
        case "$manager" in
            pkg) if ! dpkg -s "$pkg" &> /dev/null; then missing_pkgs+=("$pkg"); fi ;;
            pip) if ! pip show "$pkg" &> /dev/null; then missing_pkgs+=("$pkg"); fi ;;
            # npm ve gem için aynı mantık...
        esac
    done

    # Adım 2: Sadece eksik paketler varsa doğru yöneticiyle kurulumu başlat
	if [ ${#missing_pkgs[@]} -gt 0 ]; then
        case "$manager" in
            pkg) pkg install -y "${missing_pkgs[@]}" ;;
            pip) pip install --upgrade --break-system-packages "${missing_pkgs[@]}" ;;
            npm) npm install -g "${missing_pkgs[@]}" ;;
            gem) gem install "${missing_pkgs[@]}" ;;
        esac
    fi
}

install_tool() {
    local tool_name="$1"
    local target_dir="$Tool/$tool_name"
    local temp_dir="$Tool/${tool_name}_temp"
    local backup_target="$Backup/${tool_name}_$(date +%Y%m%d).bckp"

    # 1. Bağlantı kontrolü (Daha önce konuştuğumuz kural)
    if ! ping -c 1 8.8.8.8 &> /dev/null; then
        echo -e "\n  ${C}[${R}!${C}]${R} Cut! Please check your network connection."
        return 1
    fi

    rm -rf "$temp_dir"

    # 2. İndirmeyi dene
    if git clone --quiet "$TheDarkRoot/$tool_name.git" "$temp_dir" &> /dev/null; then
        
        # 3. Eğer araç zaten varsa, eskisini yedekle ve taşı
        if [ -d "$target_dir" ]; then
            # Önce .bckp isminde geçici olarak klasörde tut, sonra Backup'a taşı
            mv "$target_dir" "$Tool/${tool_name}.bckp"
            
            # Eğer Backup klasöründe zaten bir yedek varsa onu sil (ki çakışmasın)
            [ -d "$backup_target" ] && rm -rf "$backup_target"
            
            # Artık Backup klasörüne taşıyoruz
            mv "$Tool/${tool_name}.bckp" "$backup_target"
        fi

        # Yeni sürümü yerine koy
        mv "$temp_dir" "$target_dir"
        chmod -R +x "$target_dir"
        return 0
    else
        echo -e "\n  ${C}[${R}!${C}]${R} Error: Download failed."
        rm -rf "$temp_dir"
        return 1
    fi
}

# Backup
backup_files() {
    [ -f "$Etc/bash.bashrc" ] && cp "$Etc/bash.bashrc" "$Etc/bash.bashrc.bckp"
    [ -f "$Termux/termux.properties" ] && cp "$Termux/termux.properties" "$Termux/termux.properties.bckp"
    echo -e "\n ${C} [${Y}i${C}]${G} Backup completed."
}

# Backup Recoved
restore_files() {
    if [ -f "$Etc/bash.bashrc.bckp" ]; then
        mv "$Etc/bash.bashrc.bckp" "$Etc/bash.bashrc"
    fi
    if [ -f "$Termux/termux.properties.bckp" ]; then
        mv "$Termux/termux.properties.bckp" "$Termux/termux.properties"
    fi
    echo -e "\n ${C} [${R}!${C}]${R} Error: Backup restored successfully."
}

# Termux Tdr-Tool Updating
update_self() {
    (
     cd ~/ && curl -sLf "$Raw/Tdr-Tool/master/Tdr-Tool.sh?t=$(date +%s)" -o Tdr-Tool_temp.sh;
     rm -rf Tdr-Tool.sh && mv Tdr-Tool_temp.sh Tdr-Tool.sh && chmod +x Tdr-Tool.sh;
    ) &>> ~/.TheDarkRootTool_debug.log & spin "${C}[${Y}↓${C}]${G} Tdr-Tool Updating...${Y}" " ${W}⟫${G} Complete."
}

run_update () {
	echo -e "\n ${C} [${Y}i${C}]${G} Starting the update..."
	# Termux Permissions
	#( termux-setup-storage; termux-wake-lock && $Reload; sleep 3 ) &>> ~/.TermuxPermissions_debug.log & spin "${C}[${Y}↓${C}]${G} Permission..." " ${W}⟫${G} Complete."
	# Termux Update
	( pkg update -y; pkg upgrade -y && $Reload; ) &>> ~/.TermuxUpdate_debug.log & spin "${C}[${Y}↓${C}]${G} Updating..." " ${W}⟫${G} Complete."
	# Termux Packages Installing
	( 
      install_packages pkg termux-tools coreutils binutils git curl wget sed grep gawk bc jq ncurses-utils python ruby php clang make openssh openssl zip unzip tar proot crunch neofetch nano vim cmatrix sl tmate zsh bash tor privoxy play-audio mpv cowsay figlet toilet nodejs
      $Reload
    ) &>> ~/.TermuxPackages_debug.log & spin "${C}[${Y}↓${C}]${G} Packages Installing..." " ${W}⟫${G} Complete."

	# Termux Tools Installing
	(
	  install_packages pip setuptools wheel bs4 requests mechanize passlib progressbar2 pillow termcolor speedtest-cli
	  install_packages npm npm@latest readline-sync speed-test
	  install_packages gem lolcat
      $Reload
	) &>> ~/.TheDarkRoot_debug.log & spin "${C}[${Y}↓${C}]${G} Tools Installing..." " ${W}⟫${G} Complete."
	# Termux Tdr-Tool Updating
	update_self  # Fonksiyonu çağırıyoruz
}

run_speedtest () {
    # Bağımlılık Kontrolü
    local dependencies=("python3" "awk" "bc" "curl")
    for cmd in "${dependencies[@]}"; do
        if ! command -v "$cmd" &> /dev/null; then
            echo -e "\n  ${C}[${R}!${C}]${R} Error: '$cmd' package missing!"
            echo -e "\n  ${C}[${Y}i${C}]${G} You can install packages with the 'U' Update option."
            return 1
        fi
    done

    # 5. GEÇİCİ DOSYA YÖNETİMİ (mktemp)
    # Her çalıştırmada benzersiz dosyalar oluşturarak çakışmaları önler.
    local RAW_FILE=$(mktemp)
    local RESULT_FILE=$(mktemp)

    # 3. İŞLEM HATA YÖNETİMİ (Arka plan PID takibi)
    (
        if command -v speedtest-cli &> /dev/null; then
            speedtest-cli > "$RAW_FILE" 2>&1
        else
            [ ! -f "$Tool/speedtest.py" ] && curl -sL https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py -o "$Tool/speedtest.py"
            python3 -W ignore "$Tool/speedtest.py" > "$RAW_FILE" 2>&1
        fi
    ) & 
    local spin_pid=$!
    spin "${C}[${Y}↓${C}]${G} Testing network speed..." " ${W}⟫${G} Complete." " ${W}⟫${R} Failed!"
    wait $spin_pid

    # 1. GREP VE İNTERNET KESİNTİSİ KONTROLÜ
    # Dosya boşsa veya "Download:" verisi gelmediyse işlemi durdur.
    if [ ! -s "$RAW_FILE" ] || ! grep -q "Download:" "$RAW_FILE"; then
        echo -e "\n  ${C}[${R}!${C}]${R} Cut! Please check your network connection."
        rm -f "$RAW_FILE" "$RESULT_FILE"
        return 1
    fi

    # Verileri ayıkla
    my_ip=$(grep -oE "Testing from .* \([0-9.]+\)" "$RAW_FILE" | grep -oE "[0-9.]+" | head -n 1)
    provider=$(grep -oE "Testing from .* \(" "$RAW_FILE" | sed 's/Testing from //' | sed 's/ ($//' | sed 's/ (//')
    server_info=$(grep "Hosted by" "$RAW_FILE" | sed 's/Hosted by //' | cut -d '[' -f1 | sed 's/ *$//')
    ping_val=$(grep "Hosted by" "$RAW_FILE" | grep -oE "\[[0-9.]+ ms\]" | sed 's/\[//g' | sed 's/\]//g')
    dl_val=$(grep "Download:" "$RAW_FILE" | sed 's/Download: //')
    ul_val=$(grep "Upload:" "$RAW_FILE" | sed 's/Upload: //')

    # 2. DEĞİŞKENLERİN BOŞ KALMA RİSKİ (Varsayılan değer atama ve kontrol)
    dl_num=$(echo "$dl_val" | awk '{print $1}')
    ul_num=$(echo "$ul_val" | awk '{print $1}')
    ping_num=$(echo "$ping_val" | awk '{print $1}')

    # Regex kontrolü: Sayı değilse veya boşsa 0 ata
    [[ ! "$dl_num" =~ ^[0-9.]+$ ]] && dl_num=0
    [[ ! "$ul_num" =~ ^[0-9.]+$ ]] && ul_num=0
    [[ ! "$ping_num" =~ ^[0-9.]+$ ]] && ping_num=0

    # Kalite Hesaplama (Kodun orijinali)
    b_qual="${R} Poor" && g_qual="${R} Poor" && s_qual="${R} Poor" && v_qual="${R} Poor"
    if (( $(echo "$dl_num >= 15" | bc -l) )); then b_qual="${G} Great"; elif (( $(echo "$dl_num >= 5" | bc -l) )); then b_qual="${Y} Good"; fi
    if (( $(echo "$ping_num <= 30 && $ping_num > 0" | bc -l) && $(echo "$ul_num >= 5" | bc -l) )); then g_qual="${G} Great"; elif (( $(echo "$ping_num <= 60" | bc -l) )); then g_qual="${Y} Good"; fi
    if (( $(echo "$dl_num >= 25" | bc -l) )); then s_qual="${G} Great"; elif (( $(echo "$dl_num >= 10" | bc -l) )); then s_qual="${Y} Good"; fi
    if (( $(echo "$ul_num >= 8" | bc -l) && $(echo "$ping_num <= 40" | bc -l) )); then v_qual="${G} Great"; elif (( $(echo "$ul_num >= 3" | bc -l) )); then v_qual="${Y} Good"; fi

    # Raporlama
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

    # Temizlik ve Kayıt
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

# Kullanıcıdan girdiyi alıyoruz
read -p " $(echo -e " ${C}[${Y}~${C}]${M} Program Number: ${Y}")" pn
# ${degisken,,} -> Değişkenin içindeki tüm harfleri küçük harfe çevirir.
# ${degisken,} -> Sadece ilk harfi küçük harfe çevirir.
# ${degisken^^} -> Değişkenin içindeki tüm harfleri büyük harfe çevirir.
# ${degisken^} -> Sadece ilk harfi büyük harfe çevirir.
pn_lower="${pn,,}"

case "$pn_lower" in
    u)
        check_network # Fonksiyonu çağırıyoruz

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
		# Termux Tdr-Tool Updating
        update_self  # Fonksiyonu çağırıyoruz
        ;;

    n)
        check_network # Fonksiyonu çağırıyoruz

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
        echo -e "\n ${C} [${Y}i${C}]${G} ParrotOS-T: Parrot OS theme for Termux."

		# Yedekleme
		backup_files # Fonksiyonu çağırıyoruz

		# İndirme ve Uygulama
		(
		 if curl -sLf "$Raw/FileStore/master/Software%20Files/ParrotOS.trmx?t=$(date +%s)" -o "$Etc/bash.bashrc" && \
			curl -sLf "$Raw/FileStore/master/Software%20Files/Terkey.trmx?t=$(date +%s)" -o "$Termux/termux.properties"; then
			 $Reload
		 else
			 restore_files # Fonksiyonu çağırıyoruz
         fi
		) &>> ~/.TheDarkRoot_debug.log & spin "${C}[${Y}↓${C}]${G} Downloading ParrotOS-T..." " ${W}⟫${G} Complete."
        ;;

    t)
        echo -e "\n ${C} [${Y}i${C}]${G} TheDarkRoot-T: TheDarkRoot theme for Termux."

		# Yedekleme
		backup_files # Fonksiyonu çağırıyoruz

        (
		 if curl -sLf "$Raw/FileStore/master/Software%20Files/TheDarkRoot.trmx?t=$(date +%s)" -o "$Etc/bash.bashrc" && \
			curl -sLf "$Raw/FileStore/master/Software%20Files/Terkey.trmx?t=$(date +%s)" -o "$Termux/termux.properties"; then
			 $Reload
		 else
			 restore_files # Fonksiyonu çağırıyoruz
         fi
		) &>> ~/.TheDarkRoot_debug.log & spin "${C}[${Y}↓${C}]${G} Downloading TheDarkRoot-T..." " ${W}⟫${G} Complete."
        ;;

    x)
        check_network

        if [ "$is_online" = true ]; then
            echo -e "\n ${C} [${Y}i${C}]${G} X: TheDarkRoot All-in-One Repositories."
            
            # Tüm işlemleri tek bir alt kabukta birleştiriyoruz
            (
                install_tool "Hasher"
                install_tool "Hashgen"
                install_tool "Tertext"
                install_tool "UserID"
                
                update_self # Fonksiyonu çağırıyoruz
            ) &>> ~/.TheDarkRoot_debug.log & spin "${C}[${Y}↓${C}]${G} Downloading X..." " ${W}⟫${G} Complete."
        else
            echo -e "\n  ${C}[${R}!${C}]${R} Cut! Please check your network connection."
        fi
        ;;

    1|01)
        echo -e "\n ${C} [${Y}i${C}]${G} Hasher: This is a Hash Cracker."
        ( install_tool "Hasher" && $Reload; ) &>> ~/.TheDarkRoot_debug.log & spin "${C}[${Y}↓${C}]${G} Downloading Hasher..." " ${W}⟫${G} Complete."
        ;;

    2|02)
        echo -e "\n ${C} [${Y}i${C}]${G} Hashgen: Generate more 39 type hash."
        ( install_tool "Hashgen" && $Reload; ) &>> ~/.TheDarkRoot_debug.log & spin "${C}[${Y}↓${C}]${G} Downloading Hashgen..." " ${W}⟫${G} Complete."
        ;;

    3|03)
        echo -e "\n ${C} [${Y}i${C}]${G} Tertext: Program for creating words from letters."
        ( install_tool "Tertext" && $Reload; ) &>> ~/.TheDarkRoot_debug.log & spin "${C}[${Y}↓${C}]${G} Downloading Tertext..." " ${W}⟫${G} Complete."
        ;;

    4|04)
        echo -e "\n ${C} [${Y}i${C}]${G} UserID: Search usernames on social media."
        ( install_tool "UserID" && $Reload; ) &>> ~/.TheDarkRoot_debug.log & spin "${C}[${Y}↓${C}]${G} Downloading UserID..." " ${W}⟫${G} Complete."
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

# Eğer çıkış veya hatalı tuş değilse, ana menüye dönmek için bekle
if [[ "$pn_lower" != "q" && "$pn_lower" != "" && "$pn_lower" =~ ^(u|ut|p|t|x|1|2|3|4|n)$ ]]; then
    read -n 1 -s -p " $(echo -e "\n  ${C}[${Y}~${C}]${M} Press any key to return to main menu...${Y}")"
    
    # Sadece aracı güncelleyen veya çoklu kurulum yapan işlemlerden sonra scripti yeniden başlat
    if [[ "$pn_lower" =~ ^(u|ut|x)$ ]]; then
        echo -e "\n ${C}[${Y}i${C}]${G} Restarting Tdr-Tool..."
		sleep 2
		exec bash "$0"
    fi
fi
done