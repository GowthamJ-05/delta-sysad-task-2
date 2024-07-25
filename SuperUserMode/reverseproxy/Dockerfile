FROM httpd:latest

COPY ./gemini.club.conf /usr/local/apache2/conf/vhosts/

RUN echo 'Include /usr/local/apache2/conf/vhosts/*.conf' >> /usr/local/apache2/conf/httpd.conf && \
sed -i '/Include .*httpd-vhosts.conf/d' /usr/local/apache2/conf/httpd.conf

COPY ./frontend/ /usr/local/apache2/htdocs/

WORKDIR /usr/local/apache2/htdocs/