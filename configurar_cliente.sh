#!/bin/bash
#generar clave publica ssh y copiarla linea 23 y cambiar variables y establecerlas para el cliente 
source ./vars.sh
# Ejecutar el script en la máquina remota
ssh root@$SVIP1 << EOF
    echo "[+] Instalando sshpass y ansible..."
    echo "$PASSsv1" | sudo -S apt install -y sshpass 

    sshpass -p "$PASSsv1" ssh -o StrictHostKeyChecking=no "$USERsv1@$PCIP3" bash << EOF
    echo "$PASSsv1" | sudo -S bash -c '
    echo "[+] Cambiando contraseña de root..."
    echo "root:$PASSsv2" | chpasswd

    echo "[+] Cambiando hostname a Server..."
    hostnamectl set-hostname Cliente1

    echo "[+] Habilitando acceso root por SSH..."
    sed -i "s/^#\\?PermitRootLogin .*/PermitRootLogin yes/" /etc/ssh/sshd_config
    systemctl restart ssh
   
    EOF
   
    if [[ -f ~/.ssh/id_rsa.pub ]]; then
    read -p "[?] Ya existe una clave SSH en ~/.ssh/id_rsa.pub. ¿Deseas sobrescribirla? (s/n): " RESP
    if [[ "$RESP" == "s" || "$RESP" == "S" ]]; then
        echo "[+] Eliminando clave SSH antigua..."
        rm -f ~/.ssh/id_rsa ~/.ssh/id_rsa.pub
        echo "[+] Generando nueva clave SSH..."
        ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N ""
    else
        echo "[i] Se usará la clave SSH existente."
    fi
else
    echo "[+] Generando clave SSH..."
    ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N ""
fi

echo "[...] Esperando a que la máquina Server esté disponible en $PCIP3..."
for i in {1..10}; do
    ping -c 1 "$PCIP3" > /dev/null 2>&1 && break
    echo "Esperando... ($PCIP3)"
    sleep 3
done

echo "[+] Copiando clave SSH al root del servidor..."
sshpass -p "$PASSsv2" ssh-copy-id root@"$PCIP3"
    

    # Cambiar al usuario especificado
    su - usuario -c "

        # Verificar si el directorio ansible_cliente existe
        if [ -d '$directorio_ansible' ]; then
            cd '$directorio_ansible'
            ansible-playbook -i hosts playbook.yml
        else
            echo 'Directorio ansible_cliente no encontrado'
        fi
    "
    exit
EOF

echo "Script terminado"
