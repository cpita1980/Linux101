#!/usr/bin/env bash

# Detectar la shell actual
if [ -n "$ZSH_VERSION" ]; then
  SHELL_NAME="zsh"
elif [ -n "$BASH_VERSION" ]; then
  SHELL_NAME="bash"
else
  echo "Shell no soportada. Por favor, usa Bash o Zsh."
  exit 1
fi

# Configurar opciones de la shell
if [ "$SHELL_NAME" = "zsh" ]; then
  emulate -L zsh
  setopt kshglob
  setopt posixbuiltins
  setopt no_nomatch
elif [ "$SHELL_NAME" = "bash" ]; then
  set -o posix
fi

# Función para limpiar la pantalla
clear_screen() {
    printf "\033c"
}

# Función para pausar y esperar input del usuario
pause() {
    read -r -p "Presiona Enter para continuar..."
}

# Función para validar dirección IP
validate_ip() {
    if [[ $1 =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        return 0
    else
        return 1
    fi
}

# Función para validar puerto
validate_port() {
    if [[ $1 =~ ^[0-9]+$ ]] && [ "$1" -ge 1 ] && [ "$1" -le 65535 ]; then
        return 0
    else
        return 1
    fi
}

# Función para ejecutar Nmap
run_nmap() {
    clear_screen
    echo "Ejecutando Nmap: $1"
    eval "$1"
    echo
    pause
}

# Menú principal
while true; do
    clear_screen
    echo "=== Menú de Nmap ==="
    echo "1. Escaneo básico de puertos"
    echo "2. Escaneo de sistema operativo"
    echo "3. Escaneo de servicios y versiones"
    echo "4. Escaneo sigiloso (SYN)"
    echo "5. Escaneo UDP"
    echo "6. Escaneo de red completa"
    echo "7. Escaneo de vulnerabilidades"
    echo "8. Salir"
    echo

    read -r -p "Selecciona una opción: " choice

    case $choice in
        1)
            read -r -p "Introduce la dirección IP objetivo: " target_ip
            if ! validate_ip "$target_ip"; then
                echo "Dirección IP inválida."
                pause
                continue
            fi
            run_nmap "nmap $target_ip"
            ;;
        2)
            read -r -p "Introduce la dirección IP objetivo: " target_ip
            if ! validate_ip "$target_ip"; then
                echo "Dirección IP inválida."
                pause
                continue
            fi
            run_nmap "sudo nmap -O $target_ip"
            ;;
        3)
            read -r -p "Introduce la dirección IP objetivo: " target_ip
            if ! validate_ip "$target_ip"; then
                echo "Dirección IP inválida."
                pause
                continue
            fi
            run_nmap "nmap -sV $target_ip"
            ;;
        4)
            read -r -p "Introduce la dirección IP objetivo: " target_ip
            if ! validate_ip "$target_ip"; then
                echo "Dirección IP inválida."
                pause
                continue
            fi
            run_nmap "sudo nmap -sS $target_ip"
            ;;
        5)
            read -r -p "Introduce la dirección IP objetivo: " target_ip
            if ! validate_ip "$target_ip"; then
                echo "Dirección IP inválida."
                pause
                continue
            fi
            run_nmap "sudo nmap -sU $target_ip"
            ;;
        6)
            read -r -p "Introduce la dirección de red (ejemplo: 192.168.1.0/24): " network
            run_nmap "nmap $network"
            ;;
        7)
            read -r -p "Introduce la dirección IP objetivo: " target_ip
            if ! validate_ip "$target_ip"; then
                echo "Dirección IP inválida."
                pause
                continue
            fi
            run_nmap "nmap --script vuln $target_ip"
            ;;
        8)
            echo "Saliendo..."
            exit 0
            ;;
        *)
            echo "Opción inválida. Por favor, intenta de nuevo."
            pause
            ;;
    esac
done