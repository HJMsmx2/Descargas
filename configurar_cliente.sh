- generar clave publica ssh y copiarla linea 23 y cambiar variables y establecerlas para el cliente 
source ./vars.sh
# Ejecutar el script en la máquina remota
ssh root@$SVIP1 << EOF
    echo "[+] Instalando sshpass y ansible..."
    echo "$PASSsv1" | sudo -S apt install -y sshpass ansible

    sshpass -p "$PASSsv1" ssh -o StrictHostKeyChecking=no "$USERsv1@$SVIP0" bash << EOF
    echo "$PASSsv1" | sudo -S bash -c '
    echo "[+] Cambiando contraseña de root..."
    echo "root:$PASSsv2" | chpasswd

    echo "[+] Cambiando hostname a Server..."
    hostnamectl set-hostname Server

    echo "[+] Habilitando acceso root por SSH..."
    sed -i "s/^#\\?PermitRootLogin .*/PermitRootLogin yes/" /etc/ssh/sshd_config
    systemctl restart ssh
    echo "Conectado a $ip como $usuario"
    exit
    EOF
    

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
EOF

echo "Script terminado"
