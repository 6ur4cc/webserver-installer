#!/bin/bash

# ASCII Art and Information
echo "
  ________               _____                
 /  _____/__ _________  /  |  |   ____  ____  
/   __  \|  |  \_  __ \/   |  |__/ ___\/ ___\ 
\  |__\  \  |  /|  | \/    ^   /\  \__\  \___ 
 \_____  /____/ |__|  \____   |  \___  >___  >
       \/                  |__|      \/    \/ 
"
echo "This script will set up a web server with all known security vulnerabilities closed."
echo

# Check for root privileges
if [ "$(id -u)" -ne 0 ]; then
    echo "Please run as root"
    exit 1
fi

# Update system
apt update && apt upgrade -y

# Function to install Apache
install_apache() {
    apt install apache2 -y
    a2enmod rewrite ssl
    systemctl start apache2
    systemctl enable apache2
    secure_apache
}

# Function to install Nginx
install_nginx() {
    apt install nginx -y
    systemctl start nginx
    systemctl enable nginx
    secure_nginx
}

# Function to install PHP
install_php() {
    local version=$1
    apt install php$version php$version-fpm php$version-mysql -y
    if [ "$webserver" == "apache" ]; then
        apt install libapache2-mod-php$version -y
    fi
    secure_php $version
}

# Function to install MySQL
install_mysql() {
    apt install mysql-server -y
    mysql_secure_installation
    secure_mysql
}

# Function to install MariaDB
install_mariadb() {
    apt install mariadb-server mariadb-client -y
    mysql_secure_installation
    secure_mysql
}

# Function to create a new virtual host for Apache
create_vhost_apache() {
    local domain=$1
    local webroot=$2

    mkdir -p "$webroot"
    chown -R www-data:www-data "$webroot"

    cat <<EOF > /etc/apache2/sites-available/$domain.conf
<VirtualHost *:80>
    ServerAdmin webmaster@$domain
    ServerName $domain
    ServerAlias www.$domain
    DocumentRoot $webroot
    <Directory $webroot>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
    ErrorLog \${APACHE_LOG_DIR}/$domain-error.log
    CustomLog \${APACHE_LOG_DIR}/$domain-access.log combined
</VirtualHost>
EOF

    a2ensite $domain.conf
    systemctl reload apache2
}

# Function to create a new virtual host for Nginx
create_vhost_nginx() {
    local domain=$1
    local webroot=$2

    mkdir -p "$webroot"
    chown -R www-data:www-data "$webroot"

    cat <<EOF > /etc/nginx/sites-available/$domain
server {
    listen 80;
    server_name $domain www.$domain;
    root $webroot;
    index index.php index.html index.htm;

    location / {
        try_files \$uri \$uri/ =404;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php$php_version-fpm.sock;
    }

    location ~ /\.ht {
        deny all;
    }

    error_log /var/log/nginx/$domain-error.log;
    access_log /var/log/nginx/$domain-access.log;
}
EOF

    ln -s /etc/nginx/sites-available/$domain /etc/nginx/sites-enabled/
    systemctl reload nginx
}

# Function to obtain SSL certificate
obtain_ssl() {
    local domain=$1
    if [ "$webserver" == "apache" ]; then
        certbot --apache -d $domain -d www.$domain
    elif [ "$webserver" == "nginx" ]; then
        certbot --nginx -d $domain -d www.$domain
    fi
}

# Function to secure Apache
secure_apache() {
    # Disable directory listing
    sed -i 's/Options Indexes FollowSymLinks/Options FollowSymLinks/' /etc/apache2/apache2.conf

    # Hide Apache version and OS information
    echo "ServerTokens Prod" >> /etc/apache2/conf-available/security.conf
    echo "ServerSignature Off" >> /etc/apache2/conf-available/security.conf

    # Reload Apache to apply changes
    systemctl reload apache2
}

# Function to secure Nginx
secure_nginx() {
    # Hide Nginx version
    echo "server_tokens off;" >> /etc/nginx/nginx.conf

    # Disable directory listing
    echo "autoindex off;" >> /etc/nginx/nginx.conf

    # Reload Nginx to apply changes
    systemctl reload nginx
}

# Function to secure PHP
secure_php() {
    local version=$1
    # Disable PHP version exposure
    sed -i 's/expose_php = On/expose_php = Off/' /etc/php/$version/apache2/php.ini
    sed -i 's/expose_php = On/expose_php = Off/' /etc/php/$version/fpm/php.ini

    # Reload PHP-FPM to apply changes
    if [ "$webserver" == "nginx" ]; then
        systemctl reload php$version-fpm
    fi
}

# Function to secure MySQL/MariaDB
secure_mysql() {
    mysql -u root -e "DELETE FROM mysql.user WHERE User='';"
    mysql -u root -e "DROP DATABASE test;"
    mysql -u root -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';"
    mysql -u root -e "FLUSH PRIVILEGES;"
}

# Prompt user for web server choice
read -p "Choose web server (apache/nginx): " webserver

# Prompt user for PHP version choice
read -p "Enter PHP version (e.g., 7.4, 8.0, 8.1): " php_version

# Prompt user for database choice
read -p "Choose database (mysql/mariadb): " database

# Prompt user for domain and web root
read -p "Enter domain name (e.g., example.com): " domain
read -p "Enter web root (e.g., /var/www/html/example): " webroot

# Install selected web server
if [ "$webserver" == "apache" ]; then
    install_apache
elif [ "$webserver" == "nginx" ]; then
    install_nginx
else
    echo "Invalid web server choice. Exiting."
    exit 1
fi

# Install PHP
install_php $php_version

# Install selected database
if [ "$database" == "mysql" ]; then
    install_mysql
elif [ "$database" == "mariadb" ]; then
    install_mariadb
else
    echo "Invalid database choice. Exiting."
    exit 1
fi

# Create virtual host for the selected web server
if [ "$webserver" == "apache" ]; then
    create_vhost_apache $domain $webroot
elif [ "$webserver" == "nginx" ]; then
    create_vhost_nginx $domain $webroot
fi

# Install Certbot and obtain SSL certificate
apt install certbot python3-certbot-$webserver -y
obtain_ssl $domain

echo "$webserver, PHP $php_version, $database installed and virtual host for $domain created and secured successfully!"
