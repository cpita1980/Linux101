#!/bin/bash

# Función para detectar la distribución
detect_distribution() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$NAME
        VER=$VERSION_ID
    else
        echo "No se puede detectar la distribución. Saliendo."
        exit 1
    fi
}

# Función para instalar en sistemas basados en Debian
install_debian() {
    echo "Instalando en sistema basado en Debian..."
    
    # Actualizar el sistema
    sudo apt-get update
    sudo apt-get upgrade -y

    # Instalar Java
    sudo apt-get install default-jdk -y

    # Instalar Elasticsearch
    wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
    echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-7.x.list
    sudo apt-get update
    sudo apt-get install elasticsearch -y

    # Instalar Logstash
    sudo apt-get install logstash -y

    # Instalar Kibana
    sudo apt-get install kibana -y
}

# Función para instalar en sistemas basados en RHEL
install_rhel() {
    echo "Instalando en sistema basado en RHEL..."
    
    # Actualizar el sistema
    sudo yum update -y

    # Instalar Java
    sudo yum install java-1.8.0-openjdk -y

    # Instalar Elasticsearch
    sudo rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch
    echo "[elasticsearch-7.x]
name=Elasticsearch repository for 7.x packages
baseurl=https://artifacts.elastic.co/packages/7.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=1
autorefresh=1
type=rpm-md" | sudo tee /etc/yum.repos.d/elasticsearch.repo
    sudo yum install elasticsearch -y

    # Instalar Logstash
    sudo yum install logstash -y

    # Instalar Kibana
    sudo yum install kibana -y
}

# Función principal
main() {
    detect_distribution

    if [[ $OS == "Ubuntu" ]] || [[ $OS == "Debian"* ]]; then
        install_debian
    elif [[ $OS == "Red Hat Enterprise Linux" ]] || [[ $OS == "CentOS"* ]] || [[ $OS == "Fedora" ]]; then
        install_rhel
    else
        echo "Distribución no soportada: $OS"
        exit 1
    fi

    # Configurar y iniciar servicios
    sudo systemctl enable elasticsearch
    sudo systemctl start elasticsearch
    sudo systemctl enable logstash
    sudo systemctl start logstash
    sudo systemctl enable kibana
    sudo systemctl start kibana

    echo "Instalación del stack ELK completada en $OS."
}

# Ejecutar la función principal
main