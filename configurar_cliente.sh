
# Ejecutar el script en la máquina remota
ssh root@$SVIP1 << EOF
    echo "Conectado a $ip como $usuario"

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
