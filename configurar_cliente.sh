#!/bin/bash

# Cargar variables
source ./vars.sh

# Comprobar que todas las variables necesarias están definidas
if [[ -z "$SVIP1" || -z "$PASSsv1" || -z "$USERsv1" || -z "$PCIP3" || -z "$PASSsv2" || -z "$directorio_ansible" ]]; then
    echo "[!] Faltan variables necesarias en vars.sh"
    exit 1
fi

echo "[+] Conectando con el servidor intermedio ($SVIP1)..."
sshpass -p "$PASSsv2" ssh -o StrictHostKeyChecking=no "root@$SVIP1" bash << EOF1
    echo "[+] Instalando sshpass si es necesario..."
    apt-get update && apt-get install -y sshpass

    echo "[+] Conectando con el cliente ($PCIP3)..."
    sshpass -p "$PASSsv1" ssh -o StrictHostKeyChecking=no "$USERsv1@$PCIP3" bash << EOF2
        echo "[+] Elevando privilegios para tareas administrativas..."
        echo "$PASSsv1" | sudo -S bash -c '
            echo "[+] Cambiando contraseña del root..."
            echo "root:$PASSsv2" | chpasswd

            echo "[+] Estableciendo hostname a Cliente1..."
            hostnamectl set-hostname Cliente1

            echo "[+] Habilitando acceso SSH para root..."
            sed -i "s/^#\\?PermitRootLogin .*/PermitRootLogin yes/" /etc/ssh/sshd_config
            systemctl restart ssh
        '
EOF2

    echo "[+] Comprobando clave SSH local en el servidor..."
    if [[ ! -f ~/.ssh/id_rsa.pub ]]; then
        echo "[+] Generando nueva clave SSH..."
        ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N ""
    else
        echo "[i] Clave SSH ya existe. Usando la existente."
    fi

    echo "[+] Esperando disponibilidad del cliente ($PCIP3)..."
    for i in {1..10}; do
        ping -c 1 "$PCIP3" > /dev/null 2>&1 && break
        echo "Esperando... ($PCIP3)"
        sleep 3
    done

    echo "[+] Copiando clave SSH al cliente (root@$PCIP3)..."
    sshpass -p "$PASSsv2" ssh-copy-id -o StrictHostKeyChecking=no root@"$PCIP3"

    echo "[+] Ejecutando playbook Ansible en el servidor..."
    su - usuario -c "
        if [ -d '$directorio_ansible' ]; then
            cd '$directorio_ansible'
            ansible-playbook -i hosts playbook.yml
        else
            echo '[!] El directorio Ansible no se encontró: $directorio_ansible'
            exit 1
        fi
    "
EOF1

echo "[✔] Script terminado correctamente"
