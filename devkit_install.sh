#!/bin/bash

# =========================================================
# Linux Dev Setup
# Developer Environment Bootstrap Script
# =========================================================

echo "🚀 Atualizando os repositórios..."
sudo apt update && sudo apt upgrade -y

echo "📦 Instalando dependências básicas..."
sudo apt install -y \
    curl \
    wget \
    software-properties-common \
    flatpak \
    snapd \
    ca-certificates \
    gnupg \
    lsb-release

# =========================================================
# FLATPAK
# =========================================================

if ! flatpak remotes | grep -q flathub; then
    echo "🧩 Adicionando repositório Flathub..."
    flatpak remote-add --if-not-exists flathub \
    https://flathub.org/repo/flathub.flatpakrepo
fi

# =========================================================
# FUNÇÃO DE INSTALAÇÃO
# =========================================================

install_software() {
    SOFTWARE=$1
    FLATPAK_ID=$2
    SNAP_ID=$3
    APT_ID=$4

    echo "📥 Instalando $SOFTWARE..."

    if [ ! -z "$FLATPAK_ID" ] && flatpak install -y flathub $FLATPAK_ID 2>/dev/null; then
        echo "✅ $SOFTWARE instalado via Flatpak."

    elif [ ! -z "$SNAP_ID" ] && sudo snap install $SNAP_ID --classic 2>/dev/null; then
        echo "✅ $SOFTWARE instalado via Snap."

    elif [ ! -z "$APT_ID" ] && sudo apt install -y $APT_ID 2>/dev/null; then
        echo "✅ $SOFTWARE instalado via APT."

    else
        echo "❌ Erro ao instalar $SOFTWARE."
    fi
}

# =========================================================
# SOFTWARES
# =========================================================

install_software "Git" "" "" "git"
install_software "Postman" "com.getpostman.Postman" "postman" ""
install_software "Podman" "" "" "podman"
install_software "DBeaver" "io.dbeaver.DBeaverCommunity" "dbeaver-ce" ""
install_software "VS Code" "com.visualstudio.code" "code" ""
install_software "OBS Studio" "com.obsproject.Studio" "obs-studio" ""
install_software "Flameshot" "org.flameshot.Flameshot" "" "flameshot"
install_software "Discord" "com.discordapp.Discord" "discord" ""
install_software "VLC" "org.videolan.VLC" "" "vlc"

# =========================================================
# WARP TERMINAL
# =========================================================

if ! command -v warp &>/dev/null; then
    echo "🛰️ Instalando Warp Terminal..."

    curl -s https://warp.dev/download/linux -o warp.deb
    sudo apt install ./warp.deb -y
    rm warp.deb

else
    echo "✅ Warp Terminal já instalado."
fi

# =========================================================
# JDK 17
# =========================================================

if ! java -version 2>&1 | grep -q "17"; then
    echo "☕ Instalando JDK 17..."
    sudo apt install -y openjdk-17-jdk
else
    echo "✅ JDK 17 já instalado."
fi

# =========================================================
# PYTHON
# =========================================================

if ! command -v python3 &>/dev/null; then
    echo "🐍 Instalando Python 3..."
    sudo apt install -y python3
else
    echo "✅ Python 3 já instalado."
fi

if ! command -v pip3 &>/dev/null; then
    echo "📦 Instalando pip..."
    sudo apt install -y python3-pip
else
    echo "✅ Pip já instalado."
fi

# =========================================================
# NODE.JS
# =========================================================

if ! command -v node &>/dev/null; then
    echo "🟩 Instalando Node.js..."

    curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
    sudo apt install -y nodejs

else
    echo "✅ Node.js já instalado."
fi

if ! command -v npm &>/dev/null; then
    echo "📦 Instalando npm..."
    sudo apt install -y npm
else
    echo "✅ npm já instalado."
fi

# =========================================================
# DOCKER
# =========================================================

if ! command -v docker &>/dev/null; then

    echo "🐳 Instalando Docker..."

    # Remove versões antigas
    sudo apt remove -y docker docker-engine docker.io containerd runc

    # Adiciona chave GPG
    sudo mkdir -p /etc/apt/keyrings

    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
    sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

    sudo chmod a+r /etc/apt/keyrings/docker.gpg

    # Adiciona repositório
    echo \
      "deb [arch=$(dpkg --print-architecture) \
      signed-by=/etc/apt/keyrings/docker.gpg] \
      https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) stable" | \
      sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    sudo apt update

    # Instala Docker
    sudo apt install -y \
        docker-ce \
        docker-ce-cli \
        containerd.io \
        docker-buildx-plugin \
        docker-compose-plugin

    # Habilita serviço
    sudo systemctl enable docker
    sudo systemctl start docker

    # Adiciona usuário ao grupo docker
    sudo usermod -aG docker $USER

    echo "✅ Docker instalado com sucesso."

else
    echo "✅ Docker já instalado."
fi

# =========================================================
# FINALIZAÇÃO
# =========================================================

echo ""
echo "🎉 Todos os softwares foram instalados!"
echo ""
echo "⚠️ Para usar Docker sem sudo, execute:"
echo "newgrp docker"
echo ""
echo "🚀 Ambiente de desenvolvimento pronto."
