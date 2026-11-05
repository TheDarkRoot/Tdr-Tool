#!/usr/bin/env bash
# -*- coding: utf-8 -*-
# Tdr-Tool v1.2.8 (Alpha) - gözden geçirilmiş sürüm

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
LOG="$HOME/.TheDarkRoot_debug.log"
SCRIPT_PATH="$(readlink -f "$0" 2>/dev/null)"
MAX_BACKUPS=3
# Temaların terminal açılışında çağırdığı paketler: her zaman kurulur
THEME_PKGS="figlet toilet cowsay neofetch ncurses-utils"

# ---------------------------------------------------------------
# Log yardımcıları
# ---------------------------------------------------------------
log_step() {
    echo "[$(date '+%F %T')] $*" >> "$LOG"
}

# Log 1 MB'ı geçerse tamamen silmek yerine son 500 satırı koru
manage_logs() {
    if [ -f "$LOG" ] && [ "$(du -k "$LOG" | cut -f1)" -gt 1024 ]; then
        tail -n 500 "$LOG" > "$LOG.tmp" && mv "$LOG.tmp" "$LOG"
        log_step "Log rotated."
    fi
}
manage_logs

# ---------------------------------------------------------------
# Klasörler
# ---------------------------------------------------------------
# Yeni klasör eklemek için sadece bu listeye yolunu yaz
setup_folders=(
    "$Tool"
    "$Termux"
    "$Backup"
    "$Network"
)

for dir in "${setup_folders[@]}"; do
    [ -d "$dir" ] || mkdir -p "$dir"
done

# Depolama izni (zaman aşımlı: izin reddedilirse sonsuza dek beklemez)
if [ ! -d "$HOME/storage" ]; then
    termux-setup-storage
    for _ in $(seq 1 30); do
        [ -d "$HOME/storage" ] && break
        sleep 1
    done
    if [ -d "$HOME/storage" ]; then
        $Reload
    else
        echo -e "\n  ${C}[${Y}i${C}]${G} Storage permission not granted, continuing without it."
        sleep 1
    fi
fi

case "$1" in
    -i)
        echo -e "\n${C} #######${Y} ##################${C} #######${Y} ####################
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
${G} |${Y} [${C}=${Y}]${W} Version  ${C}:${W} v1.2.8 (Alpha)                       ${G}|
${G} |${Y} [${C}=${Y}]${W} Author   ${C}:${W} TheDarkRoot                          ${G}|
${G} |${Y} [${C}=${Y}]${W} Github   ${C}:${W} https://github.com/TheDarkRoot       ${G}|
${G} |${Y} [${C}=${Y}]${W} Telegram ${C}:${W} @TheDarkRoot (t.me/TheDarkRoot)      ${G}|
${G} 0{===================================================}0\n"
        exit 0
        ;;
    *)
        ;;
esac

# ---------------------------------------------------------------
# Ağ
# ---------------------------------------------------------------
# ICMP engelli ağlarda da çalışsın diye HTTPS ile kontrol
has_internet() {
    curl -sI --max-time 5 https://github.com &> /dev/null
}

check_network() {
    if has_internet; then
        status="${W}⟫${G} ONLINE"
        is_online=true
    else
        status="${W}⟫${R} OFFLINE"
        is_online=false
    fi

    ( sleep 0.5 ) &> /dev/null &
    spin $! "${C}[${Y}i${C}]${G} Network control..." "$status"
}

# ---------------------------------------------------------------
# Bağımlılıklar (başarısız olursa döngüye girmez)
# ---------------------------------------------------------------
check_dependencies() {
    local deps=("git" "curl" "awk" "bc" "grep")
    local missing=()
    local cmd

    for cmd in "${deps[@]}"; do
        command -v "$cmd" &> /dev/null || missing+=("$cmd")
    done

    [ ${#missing[@]} -eq 0 ] && return 0

    # Daha önce denendi ve hâlâ eksikse tekrar deneme
    if [ -n "$TDR_DEPS_TRIED" ]; then
        echo -e "\n  ${C}[${R}!${C}]${R} Still missing: ${missing[*]}. Check $LOG"
        exit 1
    fi

    echo -e "\n ${C}[${Y}i${C}]${G} Missing dependencies detected: ${missing[*]}"
    echo -e "\n ${C}[${Y}i${C}]${G} Installing automatically, please wait..."
    log_step "check_dependencies: installing ${missing[*]}"

    if pkg install -y "${missing[@]}" &>> "$LOG"; then
        echo -e "\n  ${C}[${G}✓${C}]${G} Setup complete. Restarting...\n"
        sleep 2
        export TDR_DEPS_TRIED=1
        if [ -f "$SCRIPT_PATH" ]; then
            exec bash "$SCRIPT_PATH"
        else
            echo -e "  ${C}[${Y}i${C}]${G} Please run the tool again."
            exit 0
        fi
    else
        echo -e "\n  ${C}[${R}!${C}]${R} Dependency install failed. Check $LOG"
        exit 1
    fi
}
check_dependencies

# ---------------------------------------------------------------
# Paket kurulumu
# ---------------------------------------------------------------
install_packages() {
    local manager="$1"
    shift
    local to_install=() to_update=() skipped=()
    local p key outdated=""

    # Güncel olmayan paketlerin listesini bir kez al
    case "$manager" in
        pkg) outdated=$(apt list --upgradable 2>/dev/null | awk -F/ 'NR>1 {print $1}') ;;
        pip) outdated=$(pip list --outdated --format=freeze 2>/dev/null | cut -d= -f1 | tr 'A-Z_' 'a-z-') ;;
        npm) outdated=$(npm outdated -g --parseable 2>/dev/null | awk -F: '{print $1}' | sed 's#.*/node_modules/##') ;;
        gem) outdated=$(gem outdated 2>/dev/null | awk '{print $1}') ;;
    esac

    for p in "$@"; do
        local installed=1
        case "$manager" in
            pkg) dpkg -s "$p" &> /dev/null || installed=0 ;;
            pip) pip show "$p" &> /dev/null || installed=0 ;;
            npm) npm list -g "$p" &> /dev/null || installed=0 ;;
            gem) gem list -i "^$p$" &> /dev/null || installed=0 ;;
        esac

        key="$p"
        [ "$manager" = "pip" ] && key=$(echo "$p" | tr 'A-Z_' 'a-z-')

        if [ "$installed" -eq 0 ]; then
            to_install+=("$p")
        elif echo "$outdated" | grep -qxF "$key"; then
            to_update+=("$p")
        else
            skipped+=("$p")
        fi
    done

    local rc=0
    [ ${#skipped[@]} -gt 0 ] && echo -e "\n ${C}[${Y}=${C}]${G} ($manager) Up to date, skipped: ${skipped[*]}"
    [ ${#to_update[@]} -gt 0 ] && echo -e "\n ${C}[${Y}↑${C}]${G} ($manager) Updating: ${to_update[*]}"
    [ ${#to_install[@]} -gt 0 ] && echo -e "\n ${C}[${Y}+${C}]${G} ($manager) Installing: ${to_install[*]}"

    local todo=("${to_install[@]}" "${to_update[@]}")
    if [ ${#todo[@]} -gt 0 ]; then
        case "$manager" in
            pkg) pkg install -y -o Dpkg::Options::="--force-confold" -o Dpkg::Options::="--force-confdef" "${todo[@]}" || rc=1 ;;
            pip) pip install --upgrade --break-system-packages "${todo[@]}" || rc=1 ;;
            npm)
                for p in "${todo[@]}"; do
                    npm install -g "$p@latest" || rc=1
                done
                ;;
            gem)
                for p in "${todo[@]}"; do
                    gem install "$p" || rc=1
                done
                ;;
        esac
    fi
    return $rc
}

# Eski yedekleri sınırla (son $MAX_BACKUPS kalsın)
prune_backups() {
    local name="$1"
    ls -1dt "$Backup/${name}_"*.bckp 2> /dev/null | tail -n +$((MAX_BACKUPS + 1)) | while read -r old; do
        rm -rf "$old"
    done
}

install_tool() {
    local tool_name="$1"
    local target_dir="$Tool/$tool_name"
    local temp_dir="$Tool/${tool_name}_temp"
    local backup_target="$Backup/${tool_name}_$(date +%Y%m%d_%H%M%S).bckp"

    if ! has_internet; then
        echo -e "\n  ${C}[${R}!${C}]${R} Cut! Please check your network connection."
        return 1
    fi

    rm -rf "$temp_dir"
    log_step "install_tool: $tool_name"

    if git clone --quiet "$TheDarkRoot/$tool_name.git" "$temp_dir" &>> "$LOG"; then
        # Eski sürüm varsa yedekle
        if [ -d "$target_dir" ]; then
            mv "$target_dir" "$backup_target"
            prune_backups "$tool_name"
        fi

        mv "$temp_dir" "$target_dir"
        # Sadece betiklere çalıştırma izni ver (.git vb. dokunulmaz)
        find "$target_dir" -type f \( -name "*.sh" -o -name "*.py" -o -name "*.rb" -o -name "*.php" \) \
            -exec chmod +x {} + 2>> "$LOG"
        return 0
    else
        echo -e "\n  ${C}[${R}!${C}]${R} Error: Download failed ($tool_name)."
        rm -rf "$temp_dir"
        return 1
    fi
}

# ---------------------------------------------------------------
# Yedekleme / Tema
# ---------------------------------------------------------------
backup_files() {
    [ -f "$Etc/bash.bashrc" ] && cp -f "$Etc/bash.bashrc" "$Etc/bash.bashrc.bckp"
    [ -f "$Termux/termux.properties" ] && cp -f "$Termux/termux.properties" "$Termux/termux.properties.bckp"
    echo -e "\n ${C} [${Y}i${C}]${G} Backup completed."
}

# Yedekleri kopyalayarak geri yükler (yedek dosyası silinmez)
restore_files() {
    [ -f "$Etc/bash.bashrc.bckp" ] && cp -f "$Etc/bash.bashrc.bckp" "$Etc/bash.bashrc"
    [ -f "$Termux/termux.properties.bckp" ] && cp -f "$Termux/termux.properties.bckp" "$Termux/termux.properties"
    echo -e "\n ${C} [${R}!${C}]${R} Error: Backup restored."
}

# Önce geçici dosyaya indirir, ikisi de başarılıysa yerine koyar
apply_theme_files() {
    local rc_file="$1"
    local t1 t2 ts
    t1=$(mktemp) && t2=$(mktemp) || return 1
    ts=$(date +%s)

    if curl -sLf "$Raw/FileStore/master/Software%20Files/${rc_file}.trmx?t=$ts" -o "$t1" \
       && curl -sLf "$Raw/FileStore/master/Software%20Files/Terkey.trmx?t=$ts" -o "$t2" \
       && [ -s "$t1" ] && [ -s "$t2" ]; then
        cp -f "$t1" "$Etc/bash.bashrc" && cp -f "$t2" "$Termux/termux.properties" \
            && { rm -f "$t1" "$t2"; $Reload; return 0; }
    fi
    rm -f "$t1" "$t2"
    return 1
}

install_theme() {
    local theme_name="$1"
    local rc_file label

    case "$theme_name" in
        "Parrot")
            rc_file="ParrotOS"; label="ParrotOS-T"
            echo -e "\n ${C} [${Y}i${C}]${G} ParrotOS-T: Parrot OS theme for Termux."
            ;;
        "TheDarkRoot")
            rc_file="TheDarkRoot"; label="TheDarkRoot-T"
            echo -e "\n ${C} [${Y}i${C}]${G} TheDarkRoot-T: TheDarkRoot theme for Termux."
            ;;
        *)
            echo -e "\n  ${Y}[${R}⦸${Y}]${R} Hata: Geçersiz tema adı!"
            return 1
            ;;
    esac

    if ! has_internet; then
        echo -e "\n  ${C}[${R}!${C}]${R} Cut! Please check your network connection."
        return 1
    fi

    # Tema, kurulu olmayan bir komutu çağırıp hata vermesin
    # (Update seçeneği hiç çalıştırılmamış olsa bile)
    local missing_theme_pkgs=() tp
    for tp in $THEME_PKGS; do
        dpkg -s "$tp" &> /dev/null || missing_theme_pkgs+=("$tp")
    done
    if [ ${#missing_theme_pkgs[@]} -gt 0 ]; then
        echo -e "\n ${C}[${Y}i${C}]${G} Installing theme requirements: ${missing_theme_pkgs[*]}"
        log_step "install_theme: requirements ${missing_theme_pkgs[*]}"
        if ! pkg install -y "${missing_theme_pkgs[@]}" &>> "$LOG"; then
            echo -e "\n  ${C}[${R}!${C}]${R} Theme requirements failed to install. Check $LOG"
            return 1
        fi
    fi

    backup_files
    log_step "install_theme: $theme_name"

    (
        if apply_theme_files "$rc_file"; then
            exit 0
        else
            restore_files
            exit 1
        fi
    ) &>> "$LOG" &
    spin $! "${C}[${Y}↓${C}]${G} Downloading ${label}..." " ${W}⟫${G} Complete."
}

# ---------------------------------------------------------------
# Güncelleme
# ---------------------------------------------------------------
# Spinner'sız çekirdek: indirme + sözdizimi kontrolü + atomik değiştirme
update_self_core() {
    local tmp="$HOME/Tdr-Tool_temp.sh"
    local rc=1

    log_step "update_self"
    if curl -sLf "$Raw/Tdr-Tool/master/Tdr-Tool.sh?t=$(date +%s)" -o "$tmp" \
       && [ -s "$tmp" ] \
       && bash -n "$tmp" \
       && chmod +x "$tmp" \
       && mv -f "$tmp" "$HOME/Tdr-Tool.sh"; then
        rc=0
    fi
    rm -f "$tmp"
    return $rc
}

update_self() {
    update_self_core &>> "$LOG" &
    spin $! "${C}[${Y}↓${C}]${G} Tdr-Tool Updating...${Y}" " ${W}⟫${G} Complete."
}

run_update() {
    echo -e "\n ${C} [${Y}i${C}]${G} Starting the update..."
    log_step "run_update: start"

    # 1. Termux sistem güncellemesi
    (
        export DEBIAN_FRONTEND=noninteractive
        rc=0
        pkg update -y || rc=1
        apt-get --fix-broken install -y || rc=1
        pkg upgrade -y -o Dpkg::Options::="--force-confold" -o Dpkg::Options::="--force-confdef" || rc=1
        $Reload
        exit $rc
    ) &>> "$LOG" &
    spin $! "${C}[${Y}↓${C}]${G} Updating..." " ${W}⟫${G} Complete."

    # 2. Termux paketleri (hepsi sorusuz kurulur; kuruluysa sürüm kontrolü yapılır)
    (
        rc=0
        install_packages pkg termux-tools coreutils binutils git curl wget sed grep gawk bc jq \
            ncurses-utils python ruby php clang make openssh openssl zip unzip tar proot crunch \
            neofetch nano vim cmatrix sl zsh bash tor privoxy play-audio mpv cowsay figlet toilet \
            nodejs || rc=1
        $Reload
        exit $rc
    ) &>> "$LOG" &
    spin $! "${C}[${Y}↓${C}]${G} Packages Installing..." " ${W}⟫${G} Complete."

    # 3. Pip, NPM ve Gem araçları
    (
        rc=0
        install_packages pip setuptools wheel bs4 requests mechanize passlib progressbar2 pillow termcolor speedtest-cli || rc=1
        install_packages npm readline-sync speed-test || rc=1
        install_packages gem lolcat || rc=1
        $Reload
        exit $rc
    ) &>> "$LOG" &
    spin $! "${C}[${Y}↓${C}]${G} Tools Installing..." " ${W}⟫${G} Complete."

    update_self
    log_step "run_update: end"
}

# ---------------------------------------------------------------
# Hız testi
# ---------------------------------------------------------------
run_speedtest() {
    local dependencies=("python" "awk" "bc" "curl")
    local cmd
    for cmd in "${dependencies[@]}"; do
        if ! command -v "$cmd" &> /dev/null; then
            echo -e "\n  ${C}[${R}!${C}]${R} Error: '$cmd' package missing!"
            echo -e "\n  ${C}[${Y}i${C}]${G} You can install packages with the 'U' Update option."
            return 1
        fi
    done

    local RAW_FILE RESULT_FILE
    RAW_FILE=$(mktemp)
    RESULT_FILE=$(mktemp)

    (
    if command -v speedtest-cli &> /dev/null; then
        speedtest-cli > "$RAW_FILE" 2>&1
    else
        [ ! -f "$Tool/speedtest.py" ] && curl -sL https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py -o "$Tool/speedtest.py"
        python -W ignore "$Tool/speedtest.py" > "$RAW_FILE" 2>&1
    fi
    ) &
    spin $! "${C}[${Y}↓${C}]${G} Testing network speed..." " ${W}⟫${G} Complete." " ${W}⟫${R} Failed!"

    # Dosya boşsa veya "Download:" verisi gelmediyse işlemi durdur
    if [ ! -s "$RAW_FILE" ] || ! grep -q "Download:" "$RAW_FILE"; then
        echo -e "\n  ${C}[${R}!${C}]${R} Cut! Please check your network connection."
        rm -f "$RAW_FILE" "$RESULT_FILE"
        return 1
    fi

    # Verileri ayıkla
    local my_ip provider server_info ping_val dl_val ul_val dl_num ul_num ping_num
    my_ip=$(grep -oE "Testing from .* \([0-9.]+\)" "$RAW_FILE" | grep -oE "[0-9.]+" | head -n 1)
    provider=$(grep -oE "Testing from .* \(" "$RAW_FILE" | sed 's/Testing from //' | sed 's/ ($//' | sed 's/ (//')
    server_info=$(grep "Hosted by" "$RAW_FILE" | sed 's/Hosted by //' | cut -d '[' -f1 | sed 's/ *$//')

    ping_val=$(grep -oE "([0-9.]+ ms|\[[0-9.]+ ms\])" "$RAW_FILE" | head -n 1 | sed 's/\[//g; s/\]//g')
    dl_val=$(grep "Download:" "$RAW_FILE" | sed 's/Download: //')
    ul_val=$(grep "Upload:" "$RAW_FILE" | sed 's/Upload: //')

    dl_num=$(echo "$dl_val" | awk '{print $1}')
    ul_num=$(echo "$ul_val" | awk '{print $1}')
    ping_num=$(echo "$ping_val" | awk '{print $1}')

    # Sayı değilse veya boşsa 0 ata
    [[ ! "$dl_num" =~ ^[0-9.]+$ ]] && dl_num=0
    [[ ! "$ul_num" =~ ^[0-9.]+$ ]] && ul_num=0
    [[ ! "$ping_num" =~ ^[0-9.]+$ ]] && ping_num=0

    # Kalite hesaplama
    local b_qual g_qual s_qual v_qual
    b_qual="${R} Poor"; g_qual="${R} Poor"; s_qual="${R} Poor"; v_qual="${R} Poor"
    if (( $(echo "$dl_num >= 15" | bc -l) )); then b_qual="${G} Great"; elif (( $(echo "$dl_num >= 5" | bc -l) )); then b_qual="${Y} Good"; fi

    if (( $(echo "$ping_num <= 30 && $ping_num > 0" | bc -l) && $(echo "$ul_num >= 5" | bc -l) )); then
        g_qual="${G} Great"
    elif (( $(echo "$ping_num <= 60 && $ping_num > 0" | bc -l) )); then
        g_qual="${Y} Good"
    fi

    if (( $(echo "$dl_num >= 25" | bc -l) )); then s_qual="${G} Great"; elif (( $(echo "$dl_num >= 10" | bc -l) )); then s_qual="${Y} Good"; fi
    if (( $(echo "$ul_num >= 8" | bc -l) && $(echo "$ping_num <= 40 && $ping_num > 0" | bc -l) )); then v_qual="${G} Great"; elif (( $(echo "$ul_num >= 3" | bc -l) )); then v_qual="${Y} Good"; fi

    # Raporlama
    echo -e "IP Address: $my_ip\nProvider: $provider\nServer: $server_info\nPing: $ping_val\nDownload: $dl_val\nUpload: $ul_val" > "$RESULT_FILE"
    echo -e "  ${C}======================================================${W}"
    echo -e "   ${C}[${Y}WAN${C}]${G} IP Address : ${Y}$my_ip"
    echo -e "   ${C}[${Y}ISP${C}]${G} Provider   : ${Y}$provider"
    echo -e "   ${C}[${Y}SRV${C}]${G} Server     : ${Y}$server_info"
    echo -e "   ${C}[${Y}LAT${C}]${G} Ping       : ${Y}$ping_val"
    echo -e "   ${C}[${Y}OUT${C}]${G} Download   : ${Y}$dl_val"
    echo -e "   ${C}[${Y}INP${C}]${G} Upload     : ${Y}$ul_val"
    echo -e "  ${C}------------------------------------------------------${W}"
    echo -e "   ${C}[${Y} » ${C}]${M} Browsing Quality  : ${b_qual}"
    echo -e "   ${C}[${Y} » ${C}]${M} Gaming Quality    : ${g_qual}"
    echo -e "   ${C}[${Y} » ${C}]${M} Streaming Quality : ${s_qual}"
    echo -e "   ${C}[${Y} » ${C}]${M} Video Call Quality: ${v_qual}"
    echo -e "  ${C}======================================================${W}"

    # Temizlik ve kayıt
    rm -f "$RAW_FILE"
    local save_choice log_file
    read -r -p " $(echo -e " ${C}[${Y}?${C}]${M} Do you want to save the results to a file? (Y/n): ${Y}")" save_choice
    if [[ -z "${save_choice,,}" || "${save_choice,,}" == y* ]]; then
        log_file="NetworkLog.$(date +%Y%m%d_%H%M%S).txt"
        mv "$RESULT_FILE" "$Network/$log_file"
        echo -e "\n  ${C}[${G}✓${C}]${G} Saved successfully:\n  ${C}[${G}i${C}] ${Y}$Network/$log_file"
    else
        rm -f "$RESULT_FILE"
        echo -e "\n  ${C}[${R}x${C}]${R} Results deleted."
    fi
}

# ---------------------------------------------------------------
# Spinner (4. parametre: hata mesajı)
# ---------------------------------------------------------------
spin() {
    local pid=$1
    local msg_loading="$2"
    local msg_done="$3"
    local msg_fail="${4:-${W}⟫${R} Failed!}"
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
    local i exit_code

    echo -e ""

    while kill -0 "$pid" 2>/dev/null; do
        for i in "${spinner[@]}"; do
            echo -ne "\r  $msg_loading ${C}【$i${C}】\033[K"
            sleep $delay 2>/dev/null
            kill -0 "$pid" 2>/dev/null || break
        done
    done

    # İşlemin çıkış kodunu (0: Başarılı, >0: Hata) yakala
    wait "$pid" 2>/dev/null
    exit_code=$?

    if [ $exit_code -eq 0 ]; then
        echo -e "\r  $msg_loading \033[K$msg_done"
        return 0
    else
        echo -e "\r  $msg_loading \033[K$msg_fail"
        return $exit_code
    fi
}

# ---------------------------------------------------------------
# Ana menü
# ---------------------------------------------------------------
while true; do
clear; echo -e "\n${C} #######${Y} ##################${C} #######${Y} ####################
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

read -r -p " $(echo -e " ${C}[${Y}~${C}]${M} Program Number: ${Y}")" pn
pn_lower="${pn,,}"

case "$pn_lower" in
    u)
        check_network

        if [ "$is_online" = true ]; then
            run_update

            echo -e "\n ${C} [${Y}!${C}]${G} Update completed!\n"

            read -r -p " $(echo -e " ${C}[${Y}?${C}]${M} Want to run a network speed test? (Y/n): ${Y}")" st_choice_aio

            if [[ -z "$st_choice_aio" || "${st_choice_aio,,}" == y* ]]; then
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
            read -r -p " $(echo -e " ${C}[${Y}?${C}]${M} Want to run a network speed test? (Y/n): ${Y}")" st_choice

            if [[ -z "$st_choice" || "${st_choice,,}" == y* ]]; then
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
            ) &>> "$LOG" &
            spin $! "${C}[${Y}↓${C}]${G} Downloading X..." " ${W}⟫${G} Complete."
        else
            echo -e "\n  ${C}[${R}!${C}]${R} Cut! Please check your network connection."
        fi
        ;;

    1|01)
        echo -e "\n ${C} [${Y}i${C}]${G} Hasher: This is a Hash Cracker."
        ( install_tool "Hasher" && $Reload ) &>> "$LOG" &
        spin $! "${C}[${Y}↓${C}]${G} Downloading Hasher..." " ${W}⟫${G} Complete."
        ;;

    2|02)
        echo -e "\n ${C} [${Y}i${C}]${G} Hashgen: Generate more 39 type hash."
        ( install_tool "Hashgen" && $Reload ) &>> "$LOG" &
        spin $! "${C}[${Y}↓${C}]${G} Downloading Hashgen..." " ${W}⟫${G} Complete."
        ;;

    3|03)
        echo -e "\n ${C} [${Y}i${C}]${G} Tertext: Program for creating words from letters."
        ( install_tool "Tertext" && $Reload ) &>> "$LOG" &
        spin $! "${C}[${Y}↓${C}]${G} Downloading Tertext..." " ${W}⟫${G} Complete."
        ;;

    4|04)
        echo -e "\n ${C} [${Y}i${C}]${G} UserID: Search usernames on social media."
        ( install_tool "UserID" && $Reload ) &>> "$LOG" &
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

# Çıkış veya hatalı tuş değilse ana menüye dönmek için bekle
if [[ -n "$pn_lower" && "$pn_lower" =~ ^(u|ut|p|t|x|[0-9]{1,2}|n)$ ]]; then
    read -r -n 1 -s -p " $(echo -e "\n  ${C}[${Y}~${C}]${M} Press any key to return to main menu...${Y}")"

    # Betiği güncelleyen veya çoklu kurulum yapan işlemlerden sonra yeniden başlat
    if [[ "$pn_lower" =~ ^(u|ut|x)$ ]]; then
        if [ -f "$SCRIPT_PATH" ]; then
            echo -e "\n\n  ${C}[${Y}i${C}]${G} Restarting Tdr-Tool..."
            sleep 2
            exec bash "$SCRIPT_PATH"
        fi
    fi
fi
done
