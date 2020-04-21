#!/bin/bash

echo "----------------------------------------"
echo "Script para creación directorios y permisos, configuración de Nginx, y certificados SSL (Let's Encrypt) para un sitio nuevo"
echo "----------------------------------------"

echo "1- Creación de directorios y permisos"
echo "2- Configuración Ngnix"
echo "3- Generación de certificados SSL"

echo "----------------------------------------"
read -p "Continuar? (y/n): " CONTINUE
echo "----------------------------------------"

if [ $CONTINUE = "y" ]; then
    echo "----------------------------------------"
    read -p "Ingresa tu host (puede ser subdominio): " HOST
    read -p "Ingresa tu dominio (sin punto inicial): " DOMAIN
    echo "----------------------------------------"

    echo "----------------------------------------"
    read -p "Crear directorios y permisos? (y/n): " DIRS
    echo "----------------------------------------"
    if [ $DIRS = "y" ]; then
        echo "Creando directorios y permisos"
        mkdir -p /var/www/vhosts/$HOST.$DOMAIN/{web,logs,ssl}
        chown -R www-data:www-data /var/www/vhosts/$HOST.$DOMAIN
        chmod -R 0775 /var/www/vhosts/$HOST.$DOMAIN
        sudo systemctl restart php7.4-fpm
        ps aux | grep $HOST
    fi

    echo "----------------------------------------"
    read -p "Configurar Ngnix? (y/n): " NGNIXSETUP
    echo "----------------------------------------"
    if [ $NGNIXSETUP = "y" ]; then
        sudo rm /etc/nginx/sites-available/default
        sudo rm /etc/nginx/sites-enabled/default
        cat << EOF > /etc/nginx/sites-available/$HOST.$DOMAIN
server {
    listen 80;
    server_name $HOST.$DOMAIN;
    root /var/www/vhosts/$HOST.$DOMAIN/web/public;

    add_header X-Frame-Options "SAMEORIGIN";
    add_header X-XSS-Protection "1; mode=block";
    add_header X-Content-Type-Options "nosniff";

    index index.php index.html index.htm;

    charset utf-8;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location = /robots.txt { access_log off; log_not_found off; }
    location = /favicon.ico { access_log off; log_not_found off; }
    location = /humans.txt { access_log off; log_not_found off; }
    location ~ /\. { deny all; access_log off; log_not_found off; }
    location ~ \.(neon|ini|log|yml|env|sql)$ { deny all; access_log off; log_not_found off; }

    error_page 404 /index.php;
    error_page 500 502 503 504 /custom_50x.html;
    access_log /var/www/vhosts/$HOST.$DOMAIN/logs/access.log;
    error_log /var/www/vhosts/$HOST.$DOMAIN/logs/error.log error;

    location ~ \.php$ {
        fastcgi_pass unix:/var/run/php/php7.4-fpm.sock;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME \$realpath_root\$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\.(?!well-known).* {
        deny all;
    }
}

server {
    listen 80;
    server_name www.$HOST.$DOMAIN;
    return 301 \$scheme://$HOST.$DOMAIN\$request_uri;
}
EOF
        sudo ln -s /etc/nginx/sites-available/$HOST.$DOMAIN /etc/nginx/sites-enabled/$HOST.$DOMAIN
        sudo nginx -t
        sudo nginx -s reload
        sudo systemctl restart nginx
    fi

    echo "----------------------------------------"
    read -p "Generar certificado SSL? (y/n): " SSLGEN
    echo "----------------------------------------"
    if [ $SSLGEN = "y" ]; then
        echo "Generando certificado SSL"
        sudo certbot --nginx
    fi
fi
