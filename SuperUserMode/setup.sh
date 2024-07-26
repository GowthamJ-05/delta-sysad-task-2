#!/bin/bash


HostnameChange ()
{
    sudo sed -i 's/localhost/gemini.club/g' /etc/hosts
}

setup ()
{
    HostnameChange
}

setup 
