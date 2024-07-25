#!/bin/bash

ReverseProxySetup ()
{
    sudo apt-get update

    sudo apt-get install apache2 -y 
    sudo apt-get autoclean

    sudo a2enmod proxy
    sudo a2enmod proxy_http

    sudo systemctl restart apache2

    sudo touch /etc/apache2/sites-available/gemini.club.conf

    echo '
    <VirtualHost *:80>

        ServerName gemini.club

        ProxyRequests Off
        ProxyPreserveHost On


        <location /submit-data>
            ProxyPass http://127.0.0.1:5000/
            ProxyPassReverse http://127.0.0.1:5000/
        </location>

        ErrorLog ${APACHE_LOG_DIR}/error.log
        CustomLog ${APACHE_LOG_DIR}/access.log combined
        
    </VirtualHost>' | sudo tee /etc/apache2/sites-available/gemini.club.conf >/dev/null

    sudo a2ensite gemini.club.conf

    sudo a2dissite 000-default.conf

    sudo systemctl restart apache2

}

HostnameChange ()
{
    sudo sed -i 's/localhost/gemini.club/g' /etc/hosts
}

setup ()
{
    ReverseProxySetup
    HostnameChange
}

setup 