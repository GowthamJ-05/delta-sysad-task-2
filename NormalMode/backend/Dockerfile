FROM ubuntu:latest

RUN apt-get update && \ 
apt-get install -y curl acl && \
curl -fsSL https://deb.nodesource.com/setup_lts.x | bash && \
apt-get install -y nodejs  && \
apt-get autoremove

COPY ./ /code/

WORKDIR /code/src

RUN npm install

ENV PORT 8080

EXPOSE $PORT 

ENTRYPOINT [ "bash","-c","../GeminiClubSetup/run_setup.sh;node ./index.js" ]
