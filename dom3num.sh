#!/bin/bash

##TODO:copy txt wordlists to root bashrecon folder and change code paths

if [ -z "$1" ]
then
        echo -e "\nUsage: ./dnsrecon.sh <DOMAIN.XXX>"
        exit 1
fi

printf "\n\n------ Whois DNS ------\n\n" > domresult
#printf "\n\n------ Whois DNS ------\n\n" > dns1
echo -e "\nRunning Whois DNS..."
whois $1 >> domresult
#whois $1 >> dns1
#if [ -e dns1 ]
#then
        #cat dns1
        #cat dns1 > domresult
        #rm dns1
#fi

printf "\n\n------ GOBUSTER DNS ------\n\n" >> domresult
#printf "\n\n------ GOBUSTER DNS ------\n\n" >> dns2
echo -e "\nRunning Gobuster DNS..."
gobuster dns -d $1 -t 2500 -w /usr/share/wordlists/dnsall.txt -i >> domresult
#gobuster dns -d $1 -t 40 -w /usr/share/wordlists/dnsall.txt -i >> dns2
#if [ -e dns2 ]
        #then
        #cat dns2
        #cat dns2 >> domresult
        #rm dns2
#fi

printf "\n\n------ DIG DNS ------\n\n" >> domresult
echo -e "\nRunning DIG DNS..."
dig any $1 >> domresult

printf "\n\n------ DNS RECON ------\n\n" >> domresult
echo -e "\nRunning DNSrecon..."
dnsrecon -d $1 >> domresult

printf "\n\n------ SUBDOM. SUBLIST3R ------\n\n" >> domresult
echo -e "\nRunning Sublist3r recon..."
sublist3r -d $1 >> domresult

printf "\n\n------ SUBDOM. dnsrecon ------\n\n" >> domresult
echo -e "\nRunning DNSrecon full..."
#dnsrecon -d $1 -D /usr/share/wordlists/dnsmap.txt --threads 250 -t axfr,crt,brt,std >> domresult
dnsrecon -d intelligence.htb -D /usr/share/wordlists/dnsmap.txt -t axfr >> domresult
dnsrecon -d intelligence.htb -D /usr/share/wordlists/dnsmap.txt -t crt >> domresult

printf "\n\n------ SUBDOM. BRUTE Gobuster ------\n\n" >> domresult
echo -e "\nRunning Gobuster recon..."
gobuster vhost -u $1 -t 20 -w  /usr/share/wordlists/subdomains-top1mil-20000.txt >> domresult

printf "\n\n------ SUBDOM. DNSenum ------\n\n" >> domresult
echo -e "\nRunning DNSenum recon..."
dnsenum $1 >> domresult

cat domresult
