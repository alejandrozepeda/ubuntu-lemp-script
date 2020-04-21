# Ubuntu LEMP Script

## install.sh

Script para configuración de un ambiente LEMP (Linux, Nginx, MySQL, PHP) en Ubuntu y diferentes tools:

1. Linux Updates y PPAS
2. Instalación de Linux Tools (git, unzip, zip, otros)
3. Instalación de Nginx
4. Instalación de MySQL
5. Instalación de PHP 7.4
6. Instalación de Composer
7. Instalación de Memcached
8. Instalación de Redis
9. Instalación de JS Tools (NodeJS, NPM, Gulp, Bower, Yarn, Grunt)
10. Instalación de Certbot (Let's Encrypt)

**Ejecución:**

```
cd ~
wget https://raw.githubusercontent.com/alejandrozepeda/ubuntu-lemp-script/master/install.sh
chmod u+x install.sh
sudo ./install.sh
```

## config.sh

Script para creación directorios, configuración de Nginx, y certificados SSL (Let's Encrypt) para un sitio nuevo:

1. Creación de directorios
2. Configuración Ngnix
3. Generación de certificados SSL

**Ejecución:**

```
cd ~
wget https://raw.githubusercontent.com/alejandrozepeda/ubuntu-lemp-script/master/config.sh
chmod u+x config.sh
sudo ./config.sh
```

## laravel-config.sh

Script para configuracion de permisos en un proyecto laravel:

**Ejecución:**

```
cd ~
wget https://raw.githubusercontent.com/alejandrozepeda/ubuntu-lemp-script/master/laravel-config.sh
chmod u+x laravel-config.sh
sudo ./laravel-config.sh
```
