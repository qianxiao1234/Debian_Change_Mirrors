#!/bin/bash

# Global variables for selected mirrors
SELECTED_MIRROR_DEBIAN=""
SELECTED_MIRROR_KALI=""
SELECTED_MIRROR_UBUNTU=""
SELECTED_MIRROR_CENTOS_BASE_URL="" # e.g., https://mirrors.aliyun.com/centos/
SELECTED_MIRROR_ROCKY_BASE_URL=""  # e.g., https://mirrors.aliyun.com/rockylinux/
SELECTED_MIRROR_RHEL_BASE_URL=""   # Placeholder, RHEL is complex due to subscriptions
SELECTED_MIRROR_ARCH=""
SELECTED_MIRROR_FEDORA=""

# Function to display messages
msg() {
    echo "INFO: $1"
}

warn() {
    echo "WARN: $1"
}

error_exit() {
    echo "ERROR: $1"
    exit 1
}

# Function to backup a file or directory
backup_item() {
    local item_path="$1"
    if [ -e "$item_path" ]; then
        local backup_path="${item_path}.bak_$(date +%Y%m%d%H%M%S)"
        if [ -d "$item_path" ]; then
            # For directories, copy recursively
            cp -a "$item_path" "$backup_path"
            msg "Backed up directory $item_path to $backup_path"
        else
            # For files, copy
            cp "$item_path" "$backup_path"
            msg "Backed up $item_path to $backup_path"
        fi
    else
        warn "Item $item_path not found, skipping backup."
    fi
}

# Function to select mirror
select_mirror() {
    echo "请选择软件源镜像："
    echo "1. 北京外国语大学 (BFSU)"
    echo "2. 清华大学 (TSINGHUA)"
    echo "3. 腾讯云 (TENCENT)"
    echo "4. 阿里云 (ALICLOUD)"
    echo "5. 华为云 (HUAWEI)"
    echo "6. 官方源 (OFFICIAL)"
    read -p "请输入选项 (1-6): " mirror_choice

    case $mirror_choice in
        1) # BFSU
            SELECTED_MIRROR_DEBIAN="https://mirrors.bfsu.edu.cn/debian/"
            SELECTED_MIRROR_KALI="https://mirrors.bfsu.edu.cn/kali/"
            SELECTED_MIRROR_UBUNTU="https://mirrors.bfsu.edu.cn/ubuntu/"
            SELECTED_MIRROR_CENTOS_BASE_URL="http://mirrors.bfsu.edu.cn/centos/" # Often HTTP for older CentOS
            SELECTED_MIRROR_ROCKY_BASE_URL="https://mirrors.bfsu.edu.cn/rocky/" # Assuming path, verify actual
            SELECTED_MIRROR_ARCH="https://mirrors.bfsu.edu.cn/archlinux/"
            SELECTED_MIRROR_FEDORA="http://mirrors.bfsu.edu.cn/fedora/" # Verify actual BFSU path for fedora
            msg "已选择 BFSU 镜像."
            ;;
        2) # TSINGHUA
            SELECTED_MIRROR_DEBIAN="https://mirrors.tuna.tsinghua.edu.cn/debian/"
            SELECTED_MIRROR_KALI="https://mirrors.tuna.tsinghua.edu.cn/kali/"
            SELECTED_MIRROR_UBUNTU="https://mirrors.tuna.tsinghua.edu.cn/ubuntu/"
            SELECTED_MIRROR_CENTOS_BASE_URL="https://mirrors.tuna.tsinghua.edu.cn/centos/"
            SELECTED_MIRROR_ROCKY_BASE_URL="https://mirrors.tuna.tsinghua.edu.cn/rockylinux/"
            SELECTED_MIRROR_ARCH="https://mirrors.tuna.tsinghua.edu.cn/archlinux/"
            SELECTED_MIRROR_FEDORA="https://mirrors.tuna.tsinghua.edu.cn/fedora/"
            msg "已选择 清华大学镜像."
            ;;
        3) # TENCENT
            SELECTED_MIRROR_DEBIAN="https://mirrors.cloud.tencent.com/debian/"
            SELECTED_MIRROR_KALI="https://mirrors.cloud.tencent.com/kali/"
            SELECTED_MIRROR_UBUNTU="https://mirrors.cloud.tencent.com/ubuntu/"
            SELECTED_MIRROR_CENTOS_BASE_URL="https://mirrors.cloud.tencent.com/centos/"
            SELECTED_MIRROR_ROCKY_BASE_URL="https://mirrors.cloud.tencent.com/rockylinux/"
            SELECTED_MIRROR_ARCH="https://mirrors.cloud.tencent.com/archlinux/"
            SELECTED_MIRROR_FEDORA="https://mirrors.cloud.tencent.com/fedora/"
            msg "已选择 腾讯云镜像."
            ;;
        4) # ALICLOUD
            SELECTED_MIRROR_DEBIAN="https://mirrors.aliyun.com/debian/"
            SELECTED_MIRROR_KALI="https://mirrors.aliyun.com/kali/"
            SELECTED_MIRROR_UBUNTU="https://mirrors.aliyun.com/ubuntu/"
            SELECTED_MIRROR_CENTOS_BASE_URL="https://mirrors.aliyun.com/centos/"
            SELECTED_MIRROR_ROCKY_BASE_URL="https://mirrors.aliyun.com/rockylinux/"
            SELECTED_MIRROR_ARCH="https://mirrors.aliyun.com/archlinux/"
            SELECTED_MIRROR_FEDORA="https://mirrors.aliyun.com/fedora/"
            msg "已选择 阿里云镜像."
            ;;
        5) # HUAWEI
            SELECTED_MIRROR_DEBIAN="https://mirrors.huaweicloud.com/debian/"
            SELECTED_MIRROR_KALI="https://mirrors.huaweicloud.com/kali/"
            SELECTED_MIRROR_UBUNTU="https://mirrors.huaweicloud.com/ubuntu/"
            SELECTED_MIRROR_CENTOS_BASE_URL="https://repo.huaweicloud.com/centos/" # Note: repo subdomain
            SELECTED_MIRROR_ROCKY_BASE_URL="https://repo.huaweicloud.com/rockylinux/"
            SELECTED_MIRROR_ARCH="https://repo.huaweicloud.com/archlinux/"
            SELECTED_MIRROR_FEDORA="https://repo.huaweicloud.com/fedora/"
            msg "已选择 华为云镜像."
            ;;
        6) # OFFICIAL
            SELECTED_MIRROR_DEBIAN="http://deb.debian.org/debian/"
            SELECTED_MIRROR_KALI="http://http.kali.org/kali/"
            SELECTED_MIRROR_UBUNTU="http://archive.ubuntu.com/ubuntu/"
            SELECTED_MIRROR_CENTOS_BASE_URL="OFFICIAL" # Special handling for RHEL family official
            SELECTED_MIRROR_ROCKY_BASE_URL="OFFICIAL"
            SELECTED_MIRROR_RHEL_BASE_URL="OFFICIAL"
            SELECTED_MIRROR_ARCH="OFFICIAL"
            SELECTED_MIRROR_FEDORA="OFFICIAL"
            msg "已选择 官方源."
            ;;
        *) error_exit "无效选项，退出脚本.";;
    esac
}

# Function to handle Debian/Kali
handle_debian_family() {
    local os_id="$1"
    local version_codename="$2"
    local current_mirror_url=""

    if [ "$os_id" = "debian" ]; then
        current_mirror_url="$SELECTED_MIRROR_DEBIAN"
    elif [ "$os_id" = "kali" ]; then
        current_mirror_url="$SELECTED_MIRROR_KALI"
    else
        error_exit "Unsupported Debian family OS: $os_id"
    fi

    msg "正在为 $os_id $version_codename 配置软件源..."

    # Handle DEB822 format
    if [ -f "/etc/apt/sources.list.d/debian.sources" ]; then
        msg "检测到 DEB822 sources 文件，正在替换..."
        backup_item "/etc/apt/sources.list.d/debian.sources"
        # This sed command replaces the URI for lines starting with "URIs:"
        # It assumes the structure of the debian.sources file has URIs field.
        # It might need adjustment if components also need to change based on mirror.
        sed -i -E "s|^URIs: .*|URIs: ${current_mirror_url}|" /etc/apt/sources.list.d/debian.sources
        # Add security sources if not present or ensure they are official (for Debian)
        if [ "$os_id" = "debian" ]; then
            if ! grep -q "debian-security" /etc/apt/sources.list.d/debian.sources; then
                msg "添加 Debian Security 官方源 (DEB822)..."
                # This is a simplified addition. A proper DEB822 entry is more complex.
                # For now, users should verify this part or manage security sources manually if this is too basic.
                cat <<EOF >> /etc/apt/sources.list.d/debian.sources

Types: deb
URIs: http://security.debian.org/debian-security
Suites: ${version_codename}-security
Components: main contrib non-free non-free-firmware
EOF
            else
                 # Ensure existing security URIs point to official debian-security
                 sed -i -E "s|^(URIs: .*debian-security.*)|URIs: http://security.debian.org/debian-security|" /etc/apt/sources.list.d/debian.sources
            fi
        fi
        msg "DEB822 sources 文件处理完毕！"
    else
        msg "未检测到 DEB822 sources 文件，将使用传统 sources.list 方式替换..."
        backup_item "/etc/apt/sources.list"

        if [ "$os_id" = "kali" ] && [ "$version_codename" = "kali-rolling" ]; then
            cat <<EOF > /etc/apt/sources.list
deb ${current_mirror_url} ${version_codename} main non-free contrib non-free-firmware
deb-src ${current_mirror_url} ${version_codename} main non-free contrib non-free-firmware
EOF
        elif [ "$os_id" = "debian" ]; then
            cat <<EOF > /etc/apt/sources.list
deb ${current_mirror_url} ${version_codename} main contrib non-free non-free-firmware
deb-src ${current_mirror_url} ${version_codename} main contrib non-free non-free-firmware

deb ${current_mirror_url} ${version_codename}-updates main contrib non-free non-free-firmware
deb-src ${current_mirror_url} ${version_codename}-updates main contrib non-free non-free-firmware

deb ${current_mirror_url} ${version_codename}-backports main contrib non-free non-free-firmware
deb-src ${current_mirror_url} ${version_codename}-backports main contrib non-free non-free-firmware

# Debian Security (Official)
deb http://security.debian.org/debian-security ${version_codename}-security main contrib non-free non-free-firmware
deb-src http://security.debian.org/debian-security ${version_codename}-security main contrib non-free non-free-firmware
EOF
        else
             warn "传统 sources.list 未针对 $os_id $version_codename 特别处理，请检查配置."
             # Generic fallback for other debian-like if any, copying kali logic for now
             cat <<EOF > /etc/apt/sources.list
deb ${current_mirror_url} ${version_codename} main non-free contrib non-free-firmware
deb-src ${current_mirror_url} ${version_codename} main non-free contrib non-free-firmware
EOF
        fi
        msg "传统 sources.list 文件处理完毕！"
    fi
}

# Function to handle Ubuntu
handle_ubuntu() {
    local version_codename="$1"
    local current_mirror_url="$SELECTED_MIRROR_UBUNTU"

    msg "正在为 Ubuntu $version_codename 配置软件源..."
    backup_item "/etc/apt/sources.list"
    # Ubuntu typically does not use debian.sources by default widely yet.
    # If it does, similar logic to handle_debian_family for debian.sources would be needed.
    
    cat <<EOF > /etc/apt/sources.list
deb ${current_mirror_url} ${version_codename} main restricted universe multiverse
deb-src ${current_mirror_url} ${version_codename} main restricted universe multiverse

deb ${current_mirror_url} ${version_codename}-updates main restricted universe multiverse
deb-src ${current_mirror_url} ${version_codename}-updates main restricted universe multiverse

deb ${current_mirror_url} ${version_codename}-backports main restricted universe multiverse
deb-src ${current_mirror_url} ${version_codename}-backports main restricted universe multiverse

deb http://security.ubuntu.com/ubuntu ${version_codename}-security main restricted universe multiverse
deb-src http://security.ubuntu.com/ubuntu ${version_codename}-security main restricted universe multiverse
EOF
    msg "Ubuntu sources.list 文件处理完毕！"
}

# Function to handle RHEL family (CentOS, Rocky, RHEL - very basic for RHEL)
handle_rhel_family() {
    local os_id="$1"
    local version_id="$2" # e.g., 7, 8, 9
    # local version_codename="$3" # e.g., Core, Stream, etc. Not always used in repo URLs directly

    local base_url_to_use=""
    local official_handling=false

    case "$os_id" in
        centos) base_url_to_use="$SELECTED_MIRROR_CENTOS_BASE_URL" ;;
        rocky)  base_url_to_use="$SELECTED_MIRROR_ROCKY_BASE_URL" ;;
        rhel)   
            warn "RHEL 软件源管理复杂，通常涉及订阅。此脚本仅提供基础镜像切换，可能不适用于所有 RHEL 系统或可能违反订阅协议。"
            warn "将尝试使用通用 RHEL 镜像路径，请谨慎操作。"
            base_url_to_use="$SELECTED_MIRROR_RHEL_BASE_URL" # This needs to be defined or handled if empty
            if [ -z "$base_url_to_use" ]; then
                warn "RHEL 的自定义镜像基础 URL 未在脚本中为所选镜像提供，跳过 RHEL 软件源更改。"
                msg "将维持官方源（如果之前是官方源）或现有配置。"
                return
            elif [ "$base_url_to_use" != "OFFICIAL" ]; then
                 warn "将尝试使用通用 RHEL 镜像路径 ($base_url_to_use)，请谨慎操作。"
            fi
            ;;
        *) error_exit "Unsupported RHEL family OS passed to handler: $os_id" ;;
    esac

    if [ "$base_url_to_use" = "OFFICIAL" ]; then
        official_handling=true
        msg "为 $os_id 配置官方软件源 (尝试恢复 mirrorlist)..."
    else
        msg "正在为 $os_id $version_id 配置软件源，使用镜像: $base_url_to_use"
    fi

    backup_item "/etc/yum.repos.d" # Backup the whole directory

    # Common repo names and their typical paths
    # For CentOS 7: os, updates, extras
    # For CentOS/Rocky/Alma 8/9: BaseOS, AppStream, extras, (plus, crb/powertools sometimes)
    
    # This is a generic approach. Specific repo files and section names might vary.
    for repo_file in /etc/yum.repos.d/*.repo; do
        if [ -f "$repo_file" ]; then
            msg "处理 $repo_file ..."
            # Make a specific backup of the file being modified inside the backup dir if needed,
            # but backup_item already backed up the whole dir.

            if $official_handling; then
                # Attempt to re-enable mirrorlist and disable baseurl
                sed -i -E 's/^#(mirrorlist=.*)/\1/' "$repo_file" # Uncomment mirrorlist
                sed -i -E 's/^(baseurl=.*)/#\1/' "$repo_file"    # Comment baseurl
            else
                # Disable mirrorlist, enable/set baseurl
                sed -i -E 's/^(mirrorlist=.*)/#\1/' "$repo_file" # Comment mirrorlist
                
                # This is highly generic. $releasever and $basearch should be preserved.
                # This sed attempts to replace/add baseurl using the provided pattern.
                # Example for BaseOS on Rocky: baseurl=${base_url_to_use}\$releasever/BaseOS/\$basearch/os/
                # Example for AppStream on Rocky: baseurl=${base_url_to_use}\$releasever/AppStream/\$basearch/os/
                # Example for CentOS 7 os: baseurl=${base_url_to_use}\$releasever/os/\$basearch/
                # This requires knowing the common repo names (BaseOS, AppStream, os, updates, extras)
                # A more robust solution would parse each [section] and apply logic.

                # Generic replacements for common repo names.
                # \$releasever and \$basearch must be escaped for sed if they are literal strings in the replacement.
                # If $base_url_to_use ends with a slash, don't add another.
                [[ "$base_url_to_use" != */ ]] && base_url_to_use="${base_url_to_use}/"

                # Common patterns:
                # For RHEL 8/9 family (Rocky, Alma, CentOS Stream)
                sed -i -E "s|^(#)?baseurl=http.*RockyData/Rocky-\$releasever/(.*)|baseurl=${base_url_to_use}\$releasever/\2|gI" "$repo_file" # Generic Rocky
                sed -i -E "s|^(#)?baseurl=http.*centos/\$releasever/(.*)|baseurl=${base_url_to_use}\$releasever/\2|gI" "$repo_file" # Generic CentOS

                # Targeting specific sections if possible (more robust but complex to generalize all known repo files)
                # Example for a [baseos] section:
                # sed -i "/\\[baseos\\]/,/^\$/s|^#\\?baseurl=.*|baseurl=${base_url_to_use}\\$releasever/BaseOS/\\$basearch/os/|" "$repo_file"
                # This part is complex due to variability in repo file structures.
                # The generic s/// above is a broader attempt. Users may need to verify.
                
                # A simple strategy: replace known hostnames in baseurl, keeping the path
                # This is less robust if path structures change between mirrors for the same repo.
                # Example: sed -i -E "s|^(#)?baseurl=https://[^/]+/(.*)|baseurl=${base_url_to_use}\2|gI" "$repo_file"
                # This needs careful crafting. For now, the broader replacement above is used.
                # If the base_url_to_use is the *full* path up to e.g. .../os/x86_64/, then simple replacement of the whole baseurl line is fine.
                # The current SELECTED_MIRROR_*_BASE_URL are roots like 'https://mirrors.aliyun.com/rockylinux/'
                # So we need to append the rest of the path.
                
                # For CentOS 7 (os, updates, extras)
                if [[ "$os_id" == "centos" && "$version_id" == "7" ]]; then
                    sed -i -E "s|^(#)?baseurl=http://mirror.centos.org/centos/\\\$releasever/os/\\\$basearch/|baseurl=${base_url_to_use}\\\$releasever/os/\\\$basearch/|gI" "$repo_file"
                    sed -i -E "s|^(#)?baseurl=http://mirror.centos.org/centos/\\\$releasever/updates/\\\$basearch/|baseurl=${base_url_to_use}\\\$releasever/updates/\\\$basearch/|gI" "$repo_file"
                    sed -i -E "s|^(#)?baseurl=http://mirror.centos.org/centos/\\\$releasever/extras/\\\$basearch/|baseurl=${base_url_to_use}\\\$releasever/extras/\\\$basearch/|gI" "$repo_file"
                fi
                # For RHEL 8/9 family (BaseOS, AppStream)
                if [[ "$os_id" == "rocky" || "$os_id" == "rhel" || ("$os_id" == "centos" && "$version_id" != "7") ]]; then # Assuming CentOS Stream or other 8+
                    sed -i -E "s|^(#)?baseurl=https?://[^/]+/rockylinux/\\\$releasever/BaseOS/\\\$basearch/os/|baseurl=${base_url_to_use}\\\$releasever/BaseOS/\\\$basearch/os/|gI" "$repo_file"
                    sed -i -E "s|^(#)?baseurl=https?://[^/]+/rockylinux/\\\$releasever/AppStream/\\\$basearch/os/|baseurl=${base_url_to_use}\\\$releasever/AppStream/\\\$basearch/os/|gI" "$repo_file"
                    # For CentOS Stream, paths might be different, e.g., /centos/\$stream/BaseOS/
                    # This part will need refinement for perfect accuracy across all RHEL variants & mirrors.
                    # The goal here is to replace the host and top-level path with the new mirror's base.
                    # Example: baseurl=https://dl.rockylinux.org/pub/rocky/$releasever/BaseOS/$basearch/os/
                    # becomes: baseurl=NEW_MIRROR_BASE_URL/$releasever/BaseOS/$basearch/os/
                    # We need to capture the path part after the OS name and release version.
                    # This generalized sed tries to replace the scheme and authority part of the URL.
                    # It assumes the mirror provides the standard directory structure after $base_url_to_use.
                    sed -i -E "s|^(#)?baseurl=https?://[^/]+/(centos|rockylinux|epel)/([0-9.]+|\\\$releasever|stream)/(.+)|baseurl=${base_url_to_use%/}/\3/\4|gI" "$repo_file"


                fi
            fi
        fi
    done
    msg "$os_id .repo 文件处理完毕！"
    if $official_handling; then
        msg "请运行 'dnf clean all' (或 'yum clean all') 使更改生效."
    else
        msg "请运行 'dnf clean all && dnf makecache' (或 'yum clean all && yum makecache') 更新缓存."
    fi

}

# Function to handle Arch Linux and Manjaro
handle_arch_manjaro() {
    local os_name_display="$1" 
    local mirror_base_url="$SELECTED_MIRROR_ARCH"

    msg "正在为 $os_name_display 配置软件源..."
    backup_item "/etc/pacman.d/mirrorlist"

    if [ "$mirror_base_url" = "OFFICIAL" ]; then
        msg "已选择官方源。Arch Linux/Manjaro 的官方源通常通过 /etc/pacman.d/mirrorlist 中的多个条目提供。"
        msg "建议使用 'reflector' 工具优化官方镜像列表，或确保现有列表是最新的。"
        if [ ! -s "/etc/pacman.d/mirrorlist" ] || ! grep -q -E '^\\s*Server\\s*=' /etc/pacman.d/mirrorlist; then
             msg "检测到 mirrorlist 为空或无有效服务器, 写入一个默认的地理位置分发服务器。"
             echo "Server = https://geo.mirror.pkgbuild.com/\\$repo/os/\\$arch" > /etc/pacman.d/mirrorlist
        else
            msg "此脚本不会修改现有的官方镜像列表，除非它为空。"
        fi
    elif [ -z "$mirror_base_url" ]; then
        error_exit "未选择 $os_name_display 的有效镜像 URL。"
    else
        msg "将 /etc/pacman.d/mirrorlist 替换为单个选择的镜像: $mirror_base_url"
        [[ "$mirror_base_url" != */ ]] && mirror_base_url="${mirror_base_url}/"
        cat <<EOF > /etc/pacman.d/mirrorlist
## $os_name_display repository mirrorlist generated by dcm.sh
## Selected mirror: $mirror_base_url
Server = ${mirror_base_url}\$repo/os/\$arch
EOF
    fi
    msg "$os_name_display mirrorlist 处理完毕！请运行 'sudo pacman -Syyu' 来同步和更新系统。"
}

# Function to handle Fedora
handle_fedora() {
    local version_id="$1" # $releasever
    local base_url_to_use="$SELECTED_MIRROR_FEDORA"
    local official_handling=false

    msg "正在为 Fedora $version_id 配置软件源..."

    if [ "$base_url_to_use" = "OFFICIAL" ]; then
        official_handling=true
        msg "为 Fedora 配置官方软件源 (尝试恢复 metalink)..."
    elif [ -z "$base_url_to_use" ]; then
        error_exit "未选择 Fedora 的有效镜像 URL。"
    else
        msg "使用镜像: $base_url_to_use"
    fi

    backup_item "/etc/yum.repos.d"

    for repo_file in /etc/yum.repos.d/fedora*.repo; do
        if [ -f "$repo_file" ]; then
            msg "处理 $repo_file ..."
            if $official_handling; then
                sed -i -E 's/^#(metalink=.*)/\1/' "$repo_file"
                sed -i -E 's/^(baseurl=.*)/#/\1/' "$repo_file"
            else
                sed -i -E 's/^(metalink=.*)/#/\1/' "$repo_file"
                [[ "$base_url_to_use" != */ ]] && base_url_to_use="${base_url_to_use%/}" # Ensure no trailing slash for Fedora paths usually
                
                # Replace scheme and host part of baseurl, preserving the rest of the Fedora path structure.
                # Example original: baseurl=http://dl.fedoraproject.org/pub/fedora/linux/releases/$releasever/Everything/$basearch/os/
                # Example target:   baseurl=${base_url_to_use}/releases/$releasever/Everything/$basearch/os/
                # The SELECTED_MIRROR_FEDORA is like "https://mirrors.tuna.tsinghua.edu.cn/fedora"
                # The original paths are like "/pub/fedora/linux/releases/.../" or "/linux/releases/.../"
                sed -i -E "s|^(#\\s*)?(baseurl=)https?://[^/]+/(pub/fedora/linux/|fedora/linux/|fedora/)?(releases|updates|updates-testing|development)/|\\2${base_url_to_use}/\\4/|gI" "$repo_file"
                # Ensure that baseurls that were commented out are uncommented if we set them
                sed -i -E "s|^#(baseurl=${base_url_to_use}.*)|baseurl=${base_url_to_use}.*|gI" "$repo_file"
            fi
        fi
    done
    msg "Fedora .repo 文件处理完毕！"
    if $official_handling; then
        msg "请运行 'sudo dnf clean all' 使更改生效."
    else
        msg "请运行 'sudo dnf clean all && sudo dnf makecache' 更新缓存."
    fi
}

# --- Main Script ---
echo "欢迎使用本项目，作者 酷安@浅笑科技"
echo "该脚本正在测试中，如若继续使用后出现的任何问题均与本作者无关（如系统损坏，数据丢失等）"

# 判断是否为root用户
if [ "$(id -u)" != "0" ]; then
    error_exit "请使用 root 权限运行此脚本: sudo ./dcm.sh"
fi

# 询问用户是否继续使用本脚本
read -p "是否继续执行脚本？(y/n): " answer
answer=$(echo "$answer" | tr '[:upper:]' '[:lower:]')
if [[ "$answer" != "y" ]]; then
    echo "操作已取消"
    exit 0
fi
echo "继续执行..."

# Call mirror selection
select_mirror

# Get OS information
if [ ! -f /etc/os-release ]; then
    error_exit "/etc/os-release 未找到，无法确定操作系统。"
fi

OS_ID=$(grep '^ID=' /etc/os-release | cut -d= -f2- | tr -d '"' | tr '[:upper:]' '[:lower:]')
OS_VERSION_CODENAME=$(grep '^VERSION_CODENAME=' /etc/os-release | cut -d= -f2- | tr -d '"' | tr '[:upper:]' '[:lower:]')
OS_VERSION_ID=$(grep '^VERSION_ID=' /etc/os-release | cut -d= -f2- | tr -d '"') # For RHEL family

# Fallback for VERSION_CODENAME if not present (e.g. on some CentOS/RHEL minimal)
if [ -z "$OS_VERSION_CODENAME" ] && [[ "$OS_ID" == "centos" || "$OS_ID" == "rhel" || "$OS_ID" == "rocky" || "$OS_ID" == "fedora" ]]; then
    if [ -n "$OS_VERSION_ID" ]; then
        OS_VERSION_CODENAME=$OS_VERSION_ID # Use version ID as codename if actual codename is missing
    else
        OS_VERSION_CODENAME=$(grep '^PRETTY_NAME=' /etc/os-release | cut -d= -f2- | tr -d '"' | awk '{print $3,$4}')
    fi
fi


msg "检测到操作系统: $OS_ID $OS_VERSION_CODENAME (Version ID: $OS_VERSION_ID)"

case "$OS_ID" in
    debian|kali)
        handle_debian_family "$OS_ID" "$OS_VERSION_CODENAME"
        ;;
    ubuntu)
        handle_ubuntu "$OS_VERSION_CODENAME"
        ;;
    centos|rhel|rocky)
        # Also catch AlmaLinux, Oracle Linux etc. if they have ID_LIKE=rhel fedora
        # For now, direct ID match.
        handle_rhel_family "$OS_ID" "$OS_VERSION_ID" # "$OS_VERSION_CODENAME" could be passed if needed
        ;;
    arch)
        handle_arch_manjaro "$OS_ID"
        ;;
    manjaro)
        warn "Manjaro 将尝试使用 Arch Linux 兼容的镜像。Manjaro 特定的分支和镜 estrutura 未在此版本中完全支持。"
        handle_arch_manjaro "$OS_ID"
        ;;
    fedora)
        handle_fedora "$OS_VERSION_ID"
        ;;
    *)
        # Check ID_LIKE for broader compatibility
        ID_LIKE=$(grep '^ID_LIKE=' /etc/os-release | cut -d= -f2- | tr -d '"' | tr '[:upper:]' '[:lower:]' 2>/dev/null || true)
        local handled_by_id_like=false
        if echo "$ID_LIKE" | grep -q "arch"; then
             warn "检测到类 Arch 系统 ($OS_ID via ID_LIKE=$ID_LIKE)，尝试使用 Arch Linux 逻辑..."
             handle_arch_manjaro "$OS_ID"
             handled_by_id_like=true
        elif echo "$ID_LIKE" | grep -q "fedora"; then
             warn "检测到类 Fedora 系统 ($OS_ID via ID_LIKE=$ID_LIKE)，尝试使用 Fedora 逻辑... (OS_VERSION_ID: $OS_VERSION_ID)"
             handle_fedora "$OS_VERSION_ID"
             handled_by_id_like=true
        elif echo "$ID_LIKE" | grep -q "debian"; then
             warn "检测到类 Debian 系统 ($OS_ID via ID_LIKE=$ID_LIKE)，尝试使用 Debian/Kali 逻辑..."
             if [ -n "$SELECTED_MIRROR_DEBIAN" ]; then
                  handle_debian_family "debian" "$OS_VERSION_CODENAME"
             else
                  error_exit "未选择 Debian 兼容的镜像，无法处理 $OS_ID."
             fi
             handled_by_id_like=true
        elif echo "$ID_LIKE" | grep -q "rhel" || echo "$ID_LIKE" | grep -q "centos"; then
             warn "检测到类 RHEL/CentOS 系统 ($OS_ID via ID_LIKE=$ID_LIKE)，尝试使用 RHEL 家族逻辑..."
             if [ -n "$SELECTED_MIRROR_CENTOS_BASE_URL" ]; then
                handle_rhel_family "centos" "$OS_VERSION_ID"
             else
                error_exit "未选择 RHEL/CentOS 兼容的镜像，无法处理 $OS_ID."
             fi
             handled_by_id_like=true
        fi

        if ! $handled_by_id_like; then
            error_exit "不支持的操作系统: $OS_ID. ID_LIKE: $ID_LIKE. 无法自动配置。"
        fi
        ;;
esac

msg "软件源配置执行完毕！"
if [[ "$OS_ID" == "debian" || "$OS_ID" == "ubuntu" || "$OS_ID" == "kali" || $(echo "$ID_LIKE" | grep -q "debian"; echo $?) -eq 0 ]]; then
    msg "请运行 'sudo apt update' 来更新软件源列表。"
    msg "如果需要同时更新软件包，请运行 'sudo apt update && sudo apt upgrade'"
elif [[ "$OS_ID" == "centos" || "$OS_ID" == "rhel" || "$OS_ID" == "rocky" || $(echo "$ID_LIKE" | grep -q "rhel\|fedora"; echo $?) -eq 0 ]]; then
    msg "对于 RHEL 系列 (CentOS, Rocky, RHEL等):"
    msg "如果选择了官方源, 可能已尝试恢复 mirrorlist. 请运行 'sudo dnf clean all' (或 'yum clean all')."
    msg "如果选择了第三方镜像, 请运行 'sudo dnf clean all && sudo dnf makecache' (或 'yum clean all && sudo yum makecache')."
fi

echo "感谢您的使用！"
