FROM ubuntu:latest

COPY ./ /app/

RUN apt-get update && \ 
apt-get install -y curl acl mysql-client cron && \
curl -fsSL https://deb.nodesource.com/setup_lts.x | bash && \
apt-get install -y nodejs  && \
apt-get autoremove


WORKDIR /app/src

RUN npm install

ENV PORT_NODE 8080 
ENV PORT_PHP 5000

EXPOSE $PORT_NODE $PORT_PHP

ENTRYPOINT [ "bash","-c","../GeminiClubSetup/run_setup.sh;node ./index.js" ]