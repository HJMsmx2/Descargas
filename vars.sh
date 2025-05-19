#!/bin/bash
# Variables de configuración para el script principal

USERsv1="usuario"
PASSsv1="usuario"
PASSsv2="melon"
SVIP1="192.168.237.2"     # IP fija para enp1s0
SVIP2="192.168.1.2"       # IP fija para enp2s0
PCIP3="192.168.1.3"
DIR1="/home/usuario/ansibles/hosts"
DIR2="/home/usuario/ansibles/playbooks"
INVENTORY="$DIR1/host_A-S"
PROYECTO="ADDC-HJM"
directorio_ansible="/home/usuario/ansible_cliente"  # La ruta donde se encuentra ansible_cliente
PLAYBOOK=(
    "Playbook_instalaciones.yml"
    "Playbook_KEA.yml"
    "Playbook_squid.yml"
    "Playbook_dns.yml"
    "Playbooks_cliente.yml"

)
PCIP3="192.168.1.3"



