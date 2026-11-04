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

# Sadece Termux: değilse hemen çık
if [ ! -d "/data/data/com.termux/files/home" ] || [ -z "$PREFIX" ]; then
    echo -e "\n  ${R}[!] Hata: Tdr-Tool sadece Termux üzerinde çalışır!${W}\n"
    exit 1
fi

# $HOME/   - /data/data/com.termux/files/home/
# $PREFIX/ - /data/data/com.termux/files/usr/
Etc="$PREFIX/etc"
Termux="$HOME/.termux"
Tool="$HOME/Tdr-Tool"
Backup="$HOME/Tdr-Tool/.Backup"
Network="$HOME/Tdr-Tool/.NetworkLog"
TheDarkRoot="https://github.com/TheDarkRoot"
Raw="https://raw.githubusercontent.com/TheDarkRoot"
Reload="termux-reload-settings"
Log="$HOME/.TheDarkRoot_debug.log"
SELF="$(readlink -f "${BASH_SOURCE[0]}")"

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

# 1. Termux Depolama İzni Kontrolü
if [ ! -d "$HOME/storage" ]; then
    termux-setup-storage
    until [ -d "$HOME/storage" ]; do sleep 1; done
    $Reload
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


# Log Yönetimi (tek log dosyası)
manage_logs() {
    if [ -f "$Log" ] && [ "$(du -k "$Log" | cut -f1)" -gt 1024 ]; then
        echo "$(date): Log rotated." > "$Log"
    fi
}

manage_logs

# Gerçek internet kontrolü (ICMP engelli ağlarda da çalışır)
net_ok() {
    curl -s -I --max-time 5 https://github.com &> /dev/null
}

check_network() {
    if net_ok; then
        status="${W}⟫${G} ONLINE"
        is_online=true
    else
        status="${W}⟫${R} OFFLINE"
        is_online=false
    fi

    ( sleep 1.5 ) &> /dev/null & spin "${C}[${Y}i${C}]${G} Network control..." "$status"
}

# Komut adından Termux paket adına çeviri
pkg_for_cmd() {
    case "$1" in
        awk) echo "gawk" ;;
        *)   echo "$1" ;;
    esac
}

# Bağımlılıkları kontrol eden fonksiyon
check_dependencies() {
    local deps=("git" "curl" "awk" "bc" "grep")
    local missing=() still_missing=() cmd

    for cmd in "${deps[@]}"; do
        command -v "$cmd" &> /dev/null || missing+=("$cmd")
    done

    if [ ${#missing[@]} -gt 0 ]; then
        echo -e "\n ${C}[${Y}i${C}]${G} Missing dependencies detected: ${missing[*]}"
        echo -e "\n ${C}[${Y}i${C}]${G} Installing automatically, please wait..."

        local pkgs=()
        for cmd in "${missing[@]}"; do pkgs+=("$(pkg_for_cmd "$cmd")"); done
        pkg install -y "${pkgs[@]}" &>> "$Log"

        # Kurulum gerçekten başarılı oldu mu? (yeniden başlatma döngüsünü önler)
        for cmd in "${missing[@]}"; do
            command -v "$cmd" &> /dev/null || still_missing+=("$cmd")
        done
        if [ ${#still_missing[@]} -gt 0 ]; then
            echo -e "\n  ${C}[${R}!${C}]${R} Error: could not install: ${still_missing[*]}"
            echo -e "  ${C}[${Y}i${C}]${G} Check your connection or try: pkg update && termux-change-repo"
            echo -e "  ${C}[${Y}i${C}]${G} Log: $Log\n"
            exit 1
        fi

        echo -e "\n\n  ${C}[${G}✓${C}]${G} Setup complete. Restarting...\n"
        sleep 2
        exec bash "$SELF"
    fi
}

install_packages() {
    local manager="$1"
    shift
    local missing_pkgs=() failed=() pkg
    local updated=false

    for pkg in "$@"; do
        case "$manager" in
            pkg) dpkg -s "$pkg" 2>/dev/null | grep -q '^Status: install ok installed' || missing_pkgs+=("$pkg") ;;
            pip) pip show "$pkg" &> /dev/null || missing_pkgs+=("$pkg") ;;
            npm) npm list -g "$pkg" &> /dev/null || missing_pkgs+=("$pkg") ;;
            gem) gem list -i "^$pkg$" &> /dev/null || missing_pkgs+=("$pkg") ;;
        esac
    done

    if [ ${#missing_pkgs[@]} -eq 0 ]; then
        echo -e "\n ${C}[${Y}i${C}]${G} All packages are already installed."
        return 0
    fi

    echo -e "\n ${C}[${Y}i${C}]${G} Installing: ${missing_pkgs[*]}"

    # Paketler tek tek kurulur: biri başarısız olsa bile diğerleri etkilenmez
    for pkg in "${missing_pkgs[@]}"; do
        case "$manager" in
            pkg)
                if ! pkg install -y "$pkg"; then
                    if [ "$updated" = false ]; then
                        # Paket listesi eski olabilir: bir kez güncelle ve tekrar dene
                        updated=true
                        pkg update -y
                        pkg install -y "$pkg" || failed+=("$pkg")
                    else
                        failed+=("$pkg")
                    fi
                fi
                ;;
            pip) pip install --upgrade "$pkg" || failed+=("$pkg") ;;
            npm) npm install -g "$pkg" || failed+=("$pkg") ;;
            gem) gem install "$pkg" || failed+=("$pkg") ;;
        esac
    done

    if [ ${#failed[@]} -gt 0 ]; then
        echo -e "\n ${C}[${R}!${C}]${R} Failed to install: ${failed[*]}"
        return 1
    fi
    return 0
}

install_tool() {
    local tool_name="$1"
    local target_dir="$Tool/$tool_name"
    local temp_dir="$Tool/${tool_name}_temp"
    local backup_target="$Backup/${tool_name}_$(date +%Y%m%d).bckp"

    # 1. Bağlantı kontrolü
    if ! net_ok; then
        echo -e "\n  ${C}[${R}!${C}]${R} Cut! Please check your network connection."
        return 1
    fi

    rm -rf "$temp_dir"

    # 2. İndirmeyi dene (kimlik bilgisi sorulursa takılma, hata ver)
    if GIT_TERMINAL_PROMPT=0 git clone --quiet "$TheDarkRoot/$tool_name.git" "$temp_dir" &> /dev/null; then

        # 3. Araç zaten varsa eskisini yedekle
        if [ -d "$target_dir" ]; then
            rm -rf "$backup_target"
            mv "$target_dir" "$backup_target" || { rm -rf "$temp_dir"; return 1; }
        fi

        # Yeni sürümü yerine koy
        mv "$temp_dir" "$target_dir" || return 1

        # Sadece betik dosyalarını çalıştırılabilir yap (.git hariç)
        find "$target_dir" -path "$target_dir/.git" -prune -o -type f \( -name '*.sh' -o -name '*.py' \) -exec chmod +x {} +
        return 0
    else
        echo -e "\n  ${C}[${R}!${C}]${R} Error: Download failed."
        rm -rf "$temp_dir"
        return 1
    fi
}

# Backup: orijinal dosyalar yalnızca ilk seferde yedeklenir (üzerine yazılmaz)
backup_files() {
    if [ -f "$Etc/bash.bashrc" ] && [ ! -f "$Etc/bash.bashrc.bckp" ]; then
        cp "$Etc/bash.bashrc" "$Etc/bash.bashrc.bckp"
    fi
    if [ -f "$Termux/termux.properties" ] && [ ! -f "$Termux/termux.properties.bckp" ]; then
        cp "$Termux/termux.properties" "$Termux/termux.properties.bckp"
    fi
    echo -e "\n ${C} [${Y}i${C}]${G} Backup completed."
}

# Backup Restore (yedek korunur, kopyalanır)
restore_files() {
    [ -f "$Etc/bash.bashrc.bckp" ] && cp "$Etc/bash.bashrc.bckp" "$Etc/bash.bashrc"
    [ -f "$Termux/termux.properties.bckp" ] && cp "$Termux/termux.properties.bckp" "$Termux/termux.properties"
    echo -e "\n ${C} [${Y}i${C}]${G} Backup restored."
}

# Tema uygulama: önce geçici dosyaya indirir, doğrular, sonra yerine koyar
apply_theme() {
    local file="$1" label="$2" desc="$3"
    local base="$Raw/FileStore/master/Software%20Files"
    local tmp_rc tmp_prop rc

    echo -e "\n ${C} [${Y}i${C}]${G} ${label}: ${desc}"
    backup_files

    tmp_rc=$(mktemp)
    tmp_prop=$(mktemp)

    (
        t=$(date +%s)
        if curl -sLf "$base/$file.trmx?t=$t" -o "$tmp_rc" && \
           curl -sLf "$base/Terkey.trmx?t=$t" -o "$tmp_prop" && \
           [ -s "$tmp_rc" ] && [ -s "$tmp_prop" ] && bash -n "$tmp_rc"; then
            if cp "$tmp_rc" "$Etc/bash.bashrc" && cp "$tmp_prop" "$Termux/termux.properties"; then
                $Reload
                exit 0
            fi
            restore_files
            exit 1
        fi
        exit 1
    ) &>> "$Log" & spin "${C}[${Y}↓${C}]${G} Downloading ${label}..." " ${W}⟫${G} Complete." " ${W}⟫${R} Failed! (original files kept)"
    rc=$?

    rm -f "$tmp_rc" "$tmp_prop"
    return $rc
}

install_theme() {
    case "$1" in
        "Parrot")      apply_theme "ParrotOS"    "ParrotOS-T"    "Parrot OS theme for Termux." ;;
        "TheDarkRoot") apply_theme "TheDarkRoot" "TheDarkRoot-T" "TheDarkRoot theme for Termux." ;;
        *)
            echo -e "\n  ${Y}[${R}⦸${Y}]${R} Hata: Geçersiz tema adı!"
            return 1
            ;;
    esac
}

# Tdr-Tool kendi kendini güvenli şekilde günceller
update_self_core() {
    local tmp="${SELF}.new"

    if ! curl -sLf "$Raw/Tdr-Tool/master/Tdr-Tool.sh?t=$(date +%s)" -o "$tmp"; then
        rm -f "$tmp"
        return 1
    fi

    # Boş, shebang'siz veya sözdizimi hatalı dosya kabul edilmez
    if [ ! -s "$tmp" ] || [ "$(head -c 2 "$tmp")" != "#!" ] || ! bash -n "$tmp" 2>/dev/null; then
        rm -f "$tmp"
        return 1
    fi

    chmod +x "$tmp" && mv -f "$tmp" "$SELF"
}

update_self() {
    update_self_core &>> "$Log" & spin "${C}[${Y}↓${C}]${G} Tdr-Tool Updating...${Y}" " ${W}⟫${G} Complete." " ${W}⟫${R} Failed! (current version kept)"
}

run_update () {
    echo -e "\n ${C} [${Y}i${C}]${G} Starting the update..."

    # Termux Update
    (
        export DEBIAN_FRONTEND=noninteractive
        pkg update -y && apt-get upgrade -y -o Dpkg::Options::="--force-confold" -o Dpkg::Options::="--force-confdef"
        rc=$?
        $Reload
        exit $rc
    ) &>> "$Log" & spin "${C}[${Y}↓${C}]${G} Updating..." " ${W}⟫${G} Complete." " ${W}⟫${R} Failed! See: $Log"

    # Termux Packages Installing
    (
        rc=0
        install_packages pkg termux-tools coreutils binutils git curl wget sed grep gawk bc jq ncurses-utils python python-pillow ruby php clang make openssh openssl zip unzip tar proot crunch neofetch nano vim cmatrix sl tmate zsh bash tor privoxy play-audio mpv cowsay figlet toilet nodejs || rc=1
        $Reload
        exit $rc
    ) &>> "$Log" & spin "${C}[${Y}↓${C}]${G} Packages Installing..." " ${W}⟫${G} Complete." " ${W}⟫${R} Some packages failed. See: $Log"

    # Termux Tools Installing
    (
        rc=0
        install_packages pip setuptools wheel bs4 requests mechanize passlib progressbar2 termcolor speedtest-cli || rc=1
        install_packages npm readline-sync speed-test || rc=1
        install_packages gem lolcat || rc=1
        $Reload
        exit $rc
    ) &>> "$Log" & spin "${C}[${Y}↓${C}]${G} Tools Installing..." " ${W}⟫${G} Complete." " ${W}⟫${R} Some tools failed. See: $Log"

    # Termux Tdr-Tool Updating
    update_self
}

run_speedtest () {
    # Bağımlılık Kontrolü
    local dependencies=("python3" "awk" "bc" "curl")
    local cmd
    for cmd in "${dependencies[@]}"; do
        if ! command -v "$cmd" &> /dev/null; then
            echo -e "\n  ${C}[${R}!${C}]${R} Error: '$cmd' package missing!"
            echo -e "\n  ${C}[${Y}i${C}]${G} You can install packages with the 'U' Update option."
            return 1
        fi
    done

    # Geçici dosyalar (mktemp)
    local RAW_FILE RESULT_FILE
    RAW_FILE=$(mktemp)
    RESULT_FILE=$(mktemp)

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
    wait "$spin_pid" 2>/dev/null

    # İnternet kesintisi / boş çıktı kontrolü
    if [ ! -s "$RAW_FILE" ] || ! grep -q "Download:" "$RAW_FILE"; then
        echo -e "\n  ${C}[${R}!${C}]${R} Cut! Please check your network connection."
        rm -f "$RAW_FILE" "$RESULT_FILE"
        return 1
    fi

    # Verileri ayıkla (IP yalnızca parantez içinden alınır)
    my_ip=$(grep -oE "Testing from .* \([0-9.]+\)" "$RAW_FILE" | grep -oE '\([0-9.]+\)' | tr -d '()' | head -n 1)
    provider=$(grep -oE "Testing from .* \(" "$RAW_FILE" | sed 's/Testing from //' | sed 's/ ($//' | sed 's/ (//')
    server_info=$(grep "Hosted by" "$RAW_FILE" | sed 's/Hosted by //' | cut -d '[' -f1 | sed 's/ *$//')
    ping_val=$(grep -oE "[0-9.]+ ms" "$RAW_FILE" | head -n 1)
    dl_val=$(grep "Download:" "$RAW_FILE" | sed 's/Download: //')
    ul_val=$(grep "Upload:" "$RAW_FILE" | sed 's/Upload: //')

    dl_num=$(echo "$dl_val" | awk '{print $1}')
    ul_num=$(echo "$ul_val" | awk '{print $1}')
    ping_num=$(echo "$ping_val" | awk '{print $1}')

    # Sayı değilse veya boşsa 0 ata
    [[ ! "$dl_num" =~ ^[0-9.]+$ ]] && dl_num=0
    [[ ! "$ul_num" =~ ^[0-9.]+$ ]] && ul_num=0
    [[ ! "$ping_num" =~ ^[0-9.]+$ ]] && ping_num=0

    # Ping okunamadıysa ping'e bağlı kalite hesapları "N/A" olur
    local ping_ok=false
    (( $(echo "$ping_num > 0" | bc -l) )) && ping_ok=true

    b_qual="${R} Poor"; g_qual="${R} Poor"; s_qual="${R} Poor"; v_qual="${R} Poor"
    if (( $(echo "$dl_num >= 15" | bc -l) )); then b_qual="${G} Great"; elif (( $(echo "$dl_num >= 5" | bc -l) )); then b_qual="${Y} Good"; fi
    if (( $(echo "$dl_num >= 25" | bc -l) )); then s_qual="${G} Great"; elif (( $(echo "$dl_num >= 10" | bc -l) )); then s_qual="${Y} Good"; fi

    if [ "$ping_ok" = true ]; then
        if (( $(echo "$ping_num <= 30" | bc -l) && $(echo "$ul_num >= 5" | bc -l) )); then g_qual="${G} Great"; elif (( $(echo "$ping_num <= 60" | bc -l) )); then g_qual="${Y} Good"; fi
        if (( $(echo "$ul_num >= 8" | bc -l) && $(echo "$ping_num <= 40" | bc -l) )); then v_qual="${G} Great"; elif (( $(echo "$ul_num >= 3" | bc -l) )); then v_qual="${Y} Good"; fi
    else
        g_qual="${Y} N/A (ping unreadable)"
        if (( $(echo "$ul_num >= 3" | bc -l) )); then v_qual="${Y} Good"; fi
    fi

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
    read -r -p " $(echo -e " ${C}[${Y}?${C}]${M} Do you want to save the results to a file? (Y/n): ${Y}")" save_choice
    if [[ -z "$save_choice" || "${save_choice,,}" == y* ]]; then
        log_file="NetworkLog.$(date +%Y%m%d_%H%M%S).txt"
        mv "$RESULT_FILE" "$Network/$log_file"
        echo -e "\n  ${C}[${G}✓${C}]${G} Saved successfully:\n  ${C}[${G}i${C}] ${Y}$Network/$log_file"
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
read -r -p " $(echo -e " ${C}[${Y}~${C}]${M} Program Number: ${Y}")" pn
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

            read -r -p " $(echo -e " ${C}[${Y}?${C}]${M} Want to run a network speed test? (Y/n): ${Y}")" st_choice_aio

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
            read -r -p " $(echo -e " ${C}[${Y}?${C}]${M} Want to run a network speed test? (Y/n): ${Y}")" st_choice

            if [[ -z $st_choice || "${st_choice,,}" == y* ]]; then
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
                rc=0
                install_tool "Hasher"  || rc=1
                install_tool "Hashgen" || rc=1
                install_tool "Tertext" || rc=1
                install_tool "UserID"  || rc=1
                update_self_core       || rc=1
                exit $rc
            ) &>> "$Log" & spin "${C}[${Y}↓${C}]${G} Downloading X..." " ${W}⟫${G} Complete." " ${W}⟫${R} Some downloads failed. See: $Log"
        else
            echo -e "\n  ${C}[${R}!${C}]${R} Cut! Please check your network connection."
        fi
        ;;

    1|01)
        echo -e "\n ${C} [${Y}i${C}]${G} Hasher: This is a Hash Cracker."
        ( install_tool "Hasher" && $Reload; ) &>> "$Log" & spin "${C}[${Y}↓${C}]${G} Downloading Hasher..." " ${W}⟫${G} Complete."
        ;;

    2|02)
        echo -e "\n ${C} [${Y}i${C}]${G} Hashgen: Generate more 39 type hash."
        ( install_tool "Hashgen" && $Reload; ) &>> "$Log" & spin "${C}[${Y}↓${C}]${G} Downloading Hashgen..." " ${W}⟫${G} Complete."
        ;;

    3|03)
        echo -e "\n ${C} [${Y}i${C}]${G} Tertext: Program for creating words from letters."
        ( install_tool "Tertext" && $Reload; ) &>> "$Log" & spin "${C}[${Y}↓${C}]${G} Downloading Tertext..." " ${W}⟫${G} Complete."
        ;;

    4|04)
        echo -e "\n ${C} [${Y}i${C}]${G} UserID: Search usernames on social media."
        ( install_tool "UserID" && $Reload; ) &>> "$Log" & spin "${C}[${Y}↓${C}]${G} Downloading UserID..." " ${W}⟫${G} Complete."
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
        echo -e "\n\n  ${C}[${Y}i${C}]${G} Restarting Tdr-Tool..."
		sleep 2
		exec bash "$SELF"
    fi
fi
done