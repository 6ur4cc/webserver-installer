# WebServer Installer Script

This script allows you to set up a LAMP (Linux, Apache, MySQL/MariaDB, PHP) or LEMP (Linux, Nginx, MySQL/MariaDB, PHP) stack on an Ubuntu server. The script also includes the setup for Let's Encrypt SSL certificates and the creation of virtual hosts. Additionally, it ensures that all known security vulnerabilities are addressed.

## Features

- Install Apache or Nginx web server
- Choose the PHP version to install
- Install MySQL or MariaDB database
- Secure installations by closing known security vulnerabilities
- Set up Let's Encrypt SSL certificates
- Create virtual hosts for your domains

## Usage

1. **Download the script:**
    ```bash
    wget https://raw.githubusercontent.com/6ur4cc/webserver-installer/main/webserver-installer.sh
    ```

2. **Make the script executable:**
    ```bash
    chmod +x webserver-installer.sh
    ```

3. **Run the script as root:**
    ```bash
    sudo ./webserver-installer.sh
    ```

4. **Follow the prompts:**
    - Choose the web server (Apache/Nginx)
    - Enter the PHP version (e.g., 7.4, 8.0, 8.1)
    - Choose the database (MySQL/MariaDB)
    - Enter the domain name (e.g., 6ur4cc.ge)
    - Enter the web root (e.g., /var/www/html/6ur4cc)

## Turkish README

```markdown
# WebServer Kurulum Scripti

Bu script, Ubuntu sunucunuzda LAMP (Linux, Apache, MySQL/MariaDB, PHP) veya LEMP (Linux, Nginx, MySQL/MariaDB, PHP) yığınını kurmanızı sağlar. Script ayrıca Let's Encrypt SSL sertifikaları kurulumunu ve sanal ana bilgisayarların oluşturulmasını içerir. Ayrıca, bilinen tüm güvenlik açıklarının kapatıldığından emin olur.

## Özellikler

- Apache veya Nginx web sunucusunu kurma
- Kurulacak PHP sürümünü seçme
- MySQL veya MariaDB veritabanını kurma
- Bilinen güvenlik açıklarını kapatarak güvenli kurulum
- Let's Encrypt SSL sertifikalarını kurma
- Alan adlarınız için sanal ana bilgisayarlar oluşturma

## Kullanım

1. **Scripti sunucya çek:**
    ```bash
    wget https://raw.githubusercontent.com/6ur4cc/webserver-installer/main/webserver-installer.sh
    ```

2. **Scripte gereken dosya izinlerini ver:**
    ```bash
    chmod +x webserver-installer.sh
    ```

3. **Scripti kök kullanıcı olarak çalıştır:**
    ```bash
    sudo ./webserver-installer.sh
    ```

4. **Yönergeleri takip et:**
    - Web sunucusunu seç (Apache/Nginx)
    - PHP sürümünü gir (örneğin, 7.4, 8.0, 8.1)
    - Veritabanını seç (MySQL/MariaDB)
    - Alan adı gir (örneğin, 6ur4cc.ge)
    - Web kökünü gir (örneğin, /var/www/html/6ur4cc)

## Örnek

```bash
sudo ./webserver-installer.sh
