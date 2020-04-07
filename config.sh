#!/bin/bash

echo "----------------------------------------"
echo "Script para configuración de vhosts de Nginx y FPM, creación directorios y certificados SSL (Let's Encrypt) para un sitio nuevo"
echo "----------------------------------------"

echo "1- Creación de directorios y configuración de FPM"
echo "2- Configuración Ngnix"
echo "3- Generación de certificados SSL"
echo "4- Nuevo proyecto ejemplo en dominio"

echo "----------------------------------------"
read -p "Continuar? (y/n): " CONTINUE
echo "----------------------------------------"

if [ $CONTINUE = "y" ]; then
    echo "----------------------------------------"
    read -p "Ingresa tu host: " HOST
    read -p "Ingresa tu dominio: " DOMAIN
    echo "----------------------------------------"

    echo "----------------------------------------"
    read -p "Crear directorios y configurar FPM? (y/n): " DIRS
    echo "----------------------------------------"
    if [ $DIRS = "y" ]; then
        echo "Creando directorios y configurando FPM"
        mkdir -p /var/www/vhosts/$HOST.$DOMAIN/{web,logs,ssl}

        groupadd $HOST
        useradd -g $HOST -d /var/www/vhosts/$HOST.$DOMAIN $HOST
        passwd $HOST
        usermod -s /bin/bash $HOST

        chown -R $HOST:$HOST /var/www/vhosts/$HOST.$DOMAIN
        chmod -R 0775 /var/www/vhosts/$HOST.$DOMAIN
        touch /etc/php/7.4/fpm/pool.d/$HOST.$DOMAIN.conf

        cat << EOF > /etc/php/7.4/fpm/pool.d/$HOST.$DOMAIN.conf
[$HOST]
user = $HOST
group = $HOST
listen = /run/php/php7.4-fpm-$HOST.sock
listen.owner = www-data
listen.group = www-data
php_admin_value[disable_functions] = exec,passthru,shell_exec,system
php_admin_flag[allow_url_fopen] = off
pm = dynamic
pm.max_children = 5
pm.start_servers = 2
pm.min_spare_servers = 1
pm.max_spare_servers = 3
chdir = /
EOF
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
    server_name www.$HOST.$DOMAIN;

    location ~ ^/\.well-known/(.*) {

    }

    location / {
        return 302 http://$HOST.$DOMAIN\$request_uri;
    }
}

server {
    listen 80;

    root /var/www/vhosts/$HOST.$DOMAIN/web/public;
    index index.php index.html index.htm;

    server_name $HOST.$DOMAIN;

    add_header X-Frame-Options "SAMEORIGIN";
    add_header X-XSS-Protection "1; mode=block";
    add_header X-Content-Type-Options "nosniff";

    charset utf-8;
    sendfile off;
    underscores_in_headers on;
    client_max_body_size 100M;
    client_body_buffer_size 128k;

    error_page 404 /index.php;
    error_page 500 502 503 504 /custom_50x.html;
    access_log /var/www/vhosts/$HOST.$DOMAIN/logs/access.log;
    error_log /var/www/vhosts/$HOST.$DOMAIN/logs/error.log error;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    # Deny access to configuration files
    location ~ \.(neon|ini|log|yml|env|sql)$ {
        deny all;
    }

    # Turn off access logs for commong files
    location = /robots.txt  {
        access_log off;
        log_not_found off;
    }

    location = /humans.txt  {
        access_log off;
        log_not_found off;
    }

    location = /favicon.ico {
        access_log off;
        log_not_found off;
    }

    # Cache Static Files For As Long As Possible
    location ~* \.(ogg|ogv|svg|svgz|eot|otf|woff|woff2|mp4|m4v|webm|ttf|js|css|rss|atom|jpg|jpeg|gif|png|webp|ico|zip|tgz|gz|rar|bz2|doc|xls|exe|ppt|tar|mid|midi|wav|bmp|rtf)$ {
        access_log off;
        log_not_found off;
        add_header Cache-Control "public, no-transform, max-age=2628000";
    }

    # Allow Let's Encrypt authorization
    location ~ /.well-known {
        allow all;
    }

    # Security Settings For Better Privacy Deny Hidden Files
    location ~ /\. {
        deny all;
        access_log off;
        log_not_found off;
    }

    # Return 403 Forbidden For readme.(txt|html) or license.(txt|html)
    if (\$request_uri ~* "^.+(readme|license)\.(txt|html)$") {
        return 403;
    }

    location ~ \.php$ {
        try_files \$uri =404;
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass unix:/var/run/php/php7.4-fpm.sock;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        include fastcgi_params;
        fastcgi_intercept_errors off;
        fastcgi_buffer_size 16k;
        fastcgi_buffers 4 16k;
        fastcgi_connect_timeout 300;
        fastcgi_send_timeout 300;
        fastcgi_read_timeout 300;
        fastcgi_cache off;
    }

    location ~ /\.(?!well-known).* {
        deny all;
    }
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
