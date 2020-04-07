#!/bin/bash

echo "----------------------------------------"
echo "Script para configuración de un ambiente LEMP (Linux, Nginx, MySQL, PHP) en Ubuntu y diferentes tools"
echo "----------------------------------------"

echo "1- Linux Updates y PPAS"
echo "2- Linux Tools (git, unzip, zip)"
echo "3- Nginx"
echo "4- MySQL"
echo "5- PHP 7.2"
echo "6- Composer"
echo "7- Memcached"
echo "8- Redis"
echo "9- JS Tools (NodeJS, NPM, Gulp, Bower, Yarn, Grunt)"
echo "10- Certbot (Let's Encrypt)"

echo "----------------------------------------"
read -p "Continuar? (y/n): " CONTINUE
echo "----------------------------------------"

if [ $CONTINUE = "y" ]; then

    echo "----------------------------------------"
    read -p "Actualizar Ubuntu? (y/n): " UBUNTU
    echo "----------------------------------------"
    if [ $UBUNTU = "y" ]; then
        echo "Actualizando"
        sudo apt -y update
        sudo apt -y upgrade
        sudo apt -y dist-upgrade
        sudo apt install -y unattended-upgrades software-properties-common
        # Ajustes de seguridad automaticos
        sudo dpkg-reconfigure -plow unattended-upgrades
        # Timezone UTC
        sudo ln -sf /usr/share/zoneinfo/UTC /etc/localtime
    fi

    echo "----------------------------------------"
    read -p "Instalar Linux Tools git, unzip, zip? (y/n): " TOOLS
    echo "----------------------------------------"
    if [ $TOOLS = "y" ]; then
        echo "Instalando Linux Tools git, unzip, zip"
        sudo apt install -y git unzip zip build-essential libmcrypt4 mcrypt gcc openssl
    fi

    echo "----------------------------------------"
    read -p "Instalar Nginx? (y/n): " NGINX
    echo "----------------------------------------"
    if [ $NGINX = "y" ]; then
        echo "Instalando Nginx"
        sudo apt install -y nginx

        sed -i "s/# server_names_hash_bucket_size.*/server_names_hash_bucket_size 64;/" /etc/nginx/nginx.conf

        sudo systemctl restart nginx
        sudo systemctl status nginx
        sudo systemctl enable nginx
    fi

    echo "----------------------------------------"
    read -p "Instalar MySQL? (y/n): " MYSQL
    echo "----------------------------------------"
    if [ $MYSQL = "y" ]; then
        echo "Instalando MySQL"
        sudo apt install -y mysql-server mysql-client
        sudo mysql_secure_installation
        sudo systemctl restart mysql
        sudo systemctl status mysql
        sudo systemctl enable mysql
    fi

    echo "----------------------------------------"
    read -p "Instalar PHP 7.4? (y/n): " PHP
    echo "----------------------------------------"
    if [ $PHP = "y" ]; then
        echo "Instalando PHP 7.4"
        sudo apt-add-repository ppa:ondrej/php -y
        sudo apt-get -y update

        sudo apt install -y php7.4-fpm
        sudo apt install -y php7.4-cli
        sudo apt install -y php7.4-mbstring
        sudo apt install -y php7.4-common
        sudo apt install -y php7.4-mysql
        sudo apt install -y php7.4-pgsql
        sudo apt install -y php7.4-sqlite3
        sudo apt install -y php7.4-opcache
        sudo apt install -y php7.4-gd
        sudo apt install -y php7.4-gmp
        sudo apt install -y php7.4-bcmath
        sudo apt install -y php7.4-bz2
        sudo apt install -y php7.4-cgi
        sudo apt install -y php7.4-json
        sudo apt install -y php7.4-xml
        sudo apt install -y php7.4-soap
        sudo apt install -y php7.4-curl
        sudo apt install -y php7.4-imap
        sudo apt install -y php7.4-zip
        sudo apt install -y php7.4-intl
        sudo apt install -y php7.4-xsl
        sudo apt install -y php7.4-readline
        sudo apt install -y php-memcached
        sudo apt install -y php-xdebug

        sudo update-alternatives --set php /usr/bin/php7.4
        php -v

        # PHP CLI Ajustes
        sudo sed -i "s/memory_limit = .*/memory_limit = 512M/" /etc/php/7.4/cli/php.ini
        sudo sed -i "s/;date.timezone.*/date.timezone = UTC/" /etc/php/7.4/cli/php.ini

        # PHP FPM Ajustes
        sudo sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php/7.4/fpm/php.ini
        sudo sed -i "s/memory_limit = .*/memory_limit = 512M/" /etc/php/7.4/fpm/php.ini
        sudo sed -i "s/upload_max_filesize = .*/upload_max_filesize = 100M/" /etc/php/7.4/fpm/php.ini
        sudo sed -i "s/post_max_size = .*/post_max_size = 100M/" /etc/php/7.4/fpm/php.ini
        sudo sed -i "s/;date.timezone.*/date.timezone = UTC/" /etc/php/7.4/fpm/php.ini
        sudo sed -i "s/error_log = .*/error_log = \/var\/log\/php\/php_error.log/" /etc/php/7.4/fpm/php.ini

        echo "xdebug.remote_enable = 1" >> /etc/php/7.4/mods-available/xdebug.ini
        echo "xdebug.remote_connect_back = 1" >> /etc/php/7.4/mods-available/xdebug.ini
        echo "xdebug.remote_port = 9000" >> /etc/php/7.4/mods-available/xdebug.ini
        echo "xdebug.max_nesting_level = 512" >> /etc/php/7.4/mods-available/xdebug.ini
        echo "opcache.revalidate_freq = 0" >> /etc/php/7.4/mods-available/opcache.ini

        # Desactivar XDebug en CLI
        phpdismod -s cli xdebug

        # Copy fastcgi_params to Nginx because they broke it on the PPA
        cat > /etc/nginx/fastcgi_params << EOF
fastcgi_param   QUERY_STRING        \$query_string;
fastcgi_param   REQUEST_METHOD      \$request_method;
fastcgi_param   CONTENT_TYPE        \$content_type;
fastcgi_param   CONTENT_LENGTH      \$content_length;
fastcgi_param   SCRIPT_FILENAME     \$request_filename;
fastcgi_param   SCRIPT_NAME         \$fastcgi_script_name;
fastcgi_param   REQUEST_URI         \$request_uri;
fastcgi_param   DOCUMENT_URI        \$document_uri;
fastcgi_param   DOCUMENT_ROOT       \$document_root;
fastcgi_param   SERVER_PROTOCOL     \$server_protocol;
fastcgi_param   GATEWAY_INTERFACE   CGI/1.1;
fastcgi_param   SERVER_SOFTWARE     nginx/\$nginx_version;
fastcgi_param   REMOTE_ADDR         \$remote_addr;
fastcgi_param   REMOTE_PORT         \$remote_port;
fastcgi_param   SERVER_ADDR         \$server_addr;
fastcgi_param   SERVER_PORT         \$server_port;
fastcgi_param   SERVER_NAME         \$server_name;
fastcgi_param   HTTPS               \$https if_not_empty;
fastcgi_param   REDIRECT_STATUS     200;
EOF

        sudo systemctl restart php7.4-fpm
        sudo systemctl status php7.4-fpm
        sudo systemctl enable php7.4-fpm
    fi

    echo "----------------------------------------"
    read -p "Instalar Composer? (y/n): " COMPOSER
    echo "----------------------------------------"
    if [ $COMPOSER = "y" ]; then
        echo "Instalando Composer"
        curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/local/bin --filename=composer
    fi

    echo "----------------------------------------"
    read -p "Instalar Memcached? (y/n): " MEMCACHED
    echo "----------------------------------------"
    if [ $MEMCACHED = "y" ]; then
        echo "Instalando Memcached"
        sudo apt install -y memcached
        sudo systemctl restart memcached
        sudo systemctl status memcached
        sudo systemctl enable memcached
    fi

    echo "----------------------------------------"
    read -p "Instalar Redis? (y/n): " REDIS
    echo "----------------------------------------"
    if [ $REDIS = "y" ]; then
        echo "Instalando Redis"
        sudo apt install -y redis-server
        sudo systemctl restart redis-server
        sudo systemctl status redis-server
        sudo systemctl enable redis-server
    fi

    echo "----------------------------------------"
    read -p "Instalar NodeJS y NPM? (y/n): " NODE
    echo "----------------------------------------"
    if [ $NODE = "y" ]; then
        echo "Instalando NodeJS y NPM"
        sudo apt install -y nodejs
        sudo apt install -y npm

        read -p "Instalar Gulp, Bower, Yarn, Grunt? (y/n): " JSTOOLS
        if [ $JSTOOLS = "y" ]; then
            echo "Instalando Gulp, Bower, Yarn, Grunt"
            sudo npm install -g gulp-cli
            sudo npm install -g bower
            sudo npm install -g yarn
            sudo npm install -g grunt-cli
        fi
    fi

    echo "----------------------------------------"
    read -p "Instalar Certbot? (y/n): " CERTBOT
    echo "----------------------------------------"
    if [ $CERTBOT = "y" ]; then
        echo "Instalando Certbot"
        sudo add-apt-repository -y universe
        sudo add-apt-repository -y ppa:certbot/certbot
        sudo apt -y update
        sudo apt install -y certbot python-certbot-nginx
    fi

    echo "----------------------------------------"
    echo "Actualizando y limpieza final"
    echo "----------------------------------------"
    sudo apt -y update
    sudo apt -y upgrade
    sudo apt -y dist-upgrade
    sudo apt -y autoremove
    sudo apt -y autoclean

    echo "----------------------------------------"
    echo "Ha finalizado tu script de configuración! :)"
    echo "----------------------------------------"
fi
