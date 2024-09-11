#!/bin/bash

# Función para manejar errores
handle_error() {
    echo "Error: $1"
    exit 1
}

# Función para instalar paquetes según el sistema operativo
install_package() {
    if [ -f /etc/debian_version ]; then
        sudo apt install -y "$1"
    elif [ -f /etc/redhat-release ]; then
        sudo dnf install -y "$1"
    elif [ "$(uname)" == "Darwin" ]; then
        brew install "$1"
    else
        echo "No se pudo instalar $1. Por favor, instálalo manualmente."
        return 1
    fi
}

# Actualizar el sistema e instalar dependencias
echo "Actualizando el sistema e instalando dependencias..."
if [ -f /etc/debian_version ]; then
    sudo apt update && sudo apt install -y zsh curl git || handle_error "No se pudo actualizar el sistema o instalar dependencias"
elif [ -f /etc/redhat-release ]; then
    sudo dnf update && sudo dnf install -y zsh curl git || handle_error "No se pudo actualizar el sistema o instalar dependencias"
elif [ "$(uname)" == "Darwin" ]; then
    brew update && brew install zsh curl git || handle_error "No se pudo actualizar el sistema o instalar dependencias"
else
    handle_error "Sistema operativo no soportado"
fi

# Instalar Zsh
echo "Instalando Zsh..."
which zsh || handle_error "No se pudo instalar Zsh"

# Instalar Oh My Zsh
echo "Instalando Oh My Zsh..."
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended || handle_error "No se pudo instalar Oh My Zsh"

# Seleccionar un tema aleatorio de los 10 mejores
themes=("robbyrussell" "agnoster" "powerlevel10k/powerlevel10k" "af-magic" "bira" "candy" "cloud" "dallas" "fino" "jonathan")
selected_theme=${themes[$RANDOM % ${#themes[@]}]}

echo "Configurando el tema $selected_theme..."
sed -i.bak "s/ZSH_THEME=\"robbyrussell\"/ZSH_THEME=\"$selected_theme\"/" ~/.zshrc

# Instalar los 10 mejores plugins
plugins=("git" "zsh-autosuggestions" "zsh-syntax-highlighting" "sudo" "web-search" "colored-man-pages" "autojump" "history" "extract" "docker")

echo "Instalando y configurando plugins..."
for plugin in "${plugins[@]}"; do
    case $plugin in
        "zsh-autosuggestions" | "zsh-syntax-highlighting")
            git clone https://github.com/zsh-users/$plugin ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/$plugin
            ;;
        "autojump")
            install_package autojump
            ;;
        "docker")
            if ! command -v docker &> /dev/null; then
                echo "Docker no está instalado. Por favor, instálalo manualmente si lo necesitas."
            fi
            ;;
    esac
done

# Actualizar la línea de plugins en .zshrc
plugins_string=$(IFS=' ' ; echo "${plugins[*]}")
sed -i.bak "s/plugins=(git)/plugins=($plugins_string)/" ~/.zshrc

# Cambiar el shell predeterminado a Zsh
echo "Cambiando el shell predeterminado a Zsh..."
sudo chsh -s $(which zsh) $USER || handle_error "No se pudo cambiar el shell predeterminado"

echo "Instalación y configuración completadas. Por favor, reinicia tu terminal o ejecuta 'source ~/.zshrc' para aplicar los cambios."
echo "Tema seleccionado: $selected_theme"
echo "Plugins instalados: $plugins_string"
echo "Nota: Algunos plugins pueden requerir configuración adicional. Consulta la documentación de cada plugin para más detalles."