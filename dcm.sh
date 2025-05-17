#!/bin/bash

echo "欢迎使用本项目，作者 酷安@浅笑科技"
echo "该脚本正在测试中，如若继续使用后出现的任何问题均与本作者无关（如系统损坏，数据丢失等）"

# 判断是否为root用户
if [ $(id -u) != "0" ]; then
    echo "请使用 root 权限运行此脚本: sudo ./ucm.sh"
    exit 1
fi

# 询问用户是否继续使用本脚本
read -p "是否继续执行脚本？(y/n): " answer
answer=$(echo "$answer" | tr '[:upper:]' '[:lower:]')  # 统一转小写
if [[ "$answer" == "y" ]]; then
    echo "继续执行..."
    # 在此添加后续操作
elif [[ "$answer" == "n" ]]; then
    echo "操作已取消"
    exit 0
else
    echo "输入无效，请输入 y 或 n"
    exit 1
fi

# 判断系统是否为 Debian 或者 kali linux ，不是则退出脚本
OS_ID=$(grep '^ID=' /etc/os-release | cut -d= -f2- | tr -d '"' | tr '[:upper:]' '[:lower:]')
if [ "$OS_ID" = "debian" ]; then
    echo "系统为 Debian"
elif [ "$OS_ID" = "kali" ]; then
    echo "系统为 kali linux"
else
    echo "该系统不是 Debian 或者 kali linux"
    exit 1
fi

# 判断软件源是否为DEB822格式
if [ -f "/etc/apt/sources.list.d/debian.sources" ]; then
    echo "检测到sources文件，正在替换"
    # 创建备份文件
    # 判断备份文件是否存在，存在则跳过备份
    if [ -f "/etc/apt/sources.list.d/debian.sources.bak" ]; then
        echo "备份文件已存在，跳过备份"
    else
        cp /etc/apt/sources.list.d/debian.sources /etc/apt/sources.list.d/debian.sources.bak
        echo "已创建备份文件 /etc/apt/sources.list.d/debian.sources.bak"
    fi
    sed -i 's#^URIs: .*#URIs: https://mirrors.ustc.edu.cn/debian/#' /etc/apt/sources.list.d/debian.sources
    echo "执行完毕！"
else
    echo "未检测到sources文件，将使用传统方式替换"
    # 创建备份文件
    # 判断备份文件是否存在，存在则跳过备份
    if [ -f "/etc/apt/sources.list.bak" ]; then
        echo "备份文件已存在，跳过备份"
    else
        cp /etc/apt/sources.list /etc/apt/sources.list.bak
        echo "已创建备份文件 /etc/apt/sources.list.bak"
    fi
    # 获取版本代号
    VERSION_CODENAME=$(grep '^VERSION_CODENAME=' /etc/os-release | cut -d= -f2- | tr -d '"')
    if [ "$VERSION_CODENAME" = "kali-rolling" ]; then
        echo "当前系统为Kali Linux"
        echo "deb https://mirrors.ustc.edu.cn/kali kali-rolling main non-free non-free-firmware contrib" > /etc/apt/sources.list
        echo "deb-src https://mirrors.ustc.edu.cn/kali kali-rolling main non-free non-free-firmware contrib" >> /etc/apt/sources.list
    else
        wget -O /etc/apt/sources.list https://mirrors.ustc.edu.cn/repogen/conf/$OS_ID-https-4-$VERSION_CODENAME
    fi
    echo "执行完毕！"
fi

# 更新软件源
echo "如果需要更新软件源，则运行sudo apt update"
echo "如果需要更新软件源并更新现有软件包，则运行sudo apt update && sudo apt upgrade"

# 结束
echo "感谢您的使用！"
