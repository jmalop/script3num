#!/bin/bash

##ADD:
##464/tcp  open  kpasswd5
#53/tcp   open  domain

if [ -z "$1" ]
then
        echo -e "\nUsage: ./1p.sh <IP>"
        exit 1
fi

printf "\n\n------ NMAP ------\n\n" > results

echo -e "\n\nRunning Nmap TCP...\n"
#nmap --top-ports 10000 --open -sS --min-rate 5000 $1 | tail -n +5 | head -n -1 >> results 
#nmap -sS --top-ports 10000 --open -sV -n --min-rate 5000 $1 | tail -n +6 | head -n -4 >> results
#nmap -p- --open -sS --min-rate 5000 $1 -n -Pn | tail -n +6 | head -n -4 >> results
nmap -p- -sS --min-rate 5000 $1 -n -Pn | tail -n +6 | head -n -1 >> results

###ToOptimize
#ports=$(cat results | awk '{print $1}' | sed 's/\/tcp/,/g' | tr -d "\n" | sed '$ s/.$//' | sed 's/------PORT//g' | sed 's/,Nma//g' | sed 's/------Some//g' | sed 's/PORT//g' | sed 's/,Servic//g'  | sed 's/------//g')
ports=$(cat results | awk '{print $1}' | sed 's/\/tcp/,/g' | tr -d "\n" | sed '$ s/.$//' | sed 's/,1SF.*")//g' | sed 's/------PORT//g' | sed 's/,Nma//g' | sed 's/------Some//g' | sed 's/PORT//g' | sed 's/,Servic//g' | sed 's/------//g' | sed 's/HostNot//g')
echo $ports

cat results

while read line
do
        if [[ $line == *open* ]] && [[ $line == 445/tcp* ]] && [[ $line != *www.openssl.org* ]]
        then
                echo -e "\nRunning SMB..."
                smbclient -L //$1 -U "" -N >> tempsmb
                #crackmapexec smb $1 >> tempsmb

        elif [[ $line == *open* ]] && [[ $line == 161/tcp* ]] && [[ $line != *www.openssl.org* ]]
        then
                echo -e "\nRunning SNMP..."
                snmpwalk -c public -v2c $1 1.3.6.1.4.1.77.1.2.25 >> tempsnmp

        elif [[ $line == *open* ]] && [[ $line == 25/tcp* ]] && [[ $line != *www.openssl.org* ]]
        then
                echo -e "\nRunning SMTP..."
                smtp-user-enum -U /usr/share/wordlists/dirbuster/apache-user-enum-2.0.txt -t $1 -m 150 >> tempsmtp

        elif [[ $line == *open* ]] && [[ $line == 135/tcp* ]] && [[ $line != *www.openssl.org* ]]
        then
                echo -e "\nRunning RPC..."
                rpcdump.py -p 135 $1 >> rpcresult

        elif [[ $line == *open* ]] && [[ $line == 2049/tcp* ]] && [[ $line != *www.openssl.org* ]]
        then
                echo -e "\nRunning NFS..."
                nmap --script=nfs-showmount $1 >> tempnfs
                #/usr/sbin/showmount -e $1 >> tempnfs

        elif [[ $line == *open* ]] && [[ $line == 137/tcp* ]] && [[ $line != *www.openssl.org* ]]
        then
                echo -e "\nRunning NetBIOS..."
                nmblookup -A $1 >> tempnb
                nbtscan $1 > tempnb

        elif [[ $line == *open* ]] && [[ $line == 138/tcp* ]] && [[ $line != *www.openssl.org* ]]
        then
                echo -e "\nRunning NetBIOS..."
                nmblookup -A $1 >> tempnb
                nbtscan $1 >> tempnb

        elif [[ $line == *open* ]] && [[ $line == 139/tcp* ]] && [[ $line != *www.openssl.org* ]]
        then
                echo -e "\nRunning NetBIOS..."
                nmblookup -A $1 >> tempnb
                nbtscan $1 >> tempnb

        elif [[ $line == *open* ]] && [[ $line == *ldap* ]] && [[ $line != *www.openssl.org* ]]
        then
                echo $line > ldaptmp
                portsl=$(cat ldaptmp | awk '{print $1}' | sed 's/\/tcp/,/g' | sed '$ s/.$//')
                echo -e "\nRunning LDAP port: $portsl ..."
                printf "\n\n------ LDAP $portsl port ------\n\n" >> ldapresults
                #nmap -p $portsl --script ldap\* --reason --min-rate 5000 $1 | tail -n +5 | head -n -1 >> ldapresults
                nmap -p $portsl --script ldap-rootdse $1 | tail -n +5 | head -n -1 >> ldapresults
                rm ldaptmp
                #cat ldapresults
                #if [ -e ldapresults ]
                #then
                #        printf "\n\n------ LDAP $ports1 ------\n\n" >> results
                #        cat ldapresults >> results
                #        rm ldapresults
                #fi

        elif [[ $line == *open* ]] && [[ $line == 88/tcp* ]] && [[ $line != *www.openssl.org* ]]
        then
                echo -e "\nRunning Kerberos ..."

                nmap -p 88 --script krb5-enum-users --script-args krb5-enum-users.realm='test' $1 | tail -n +5 | head -n -1 >> temp88

        elif [[ $line == *open* ]] && [[ $line == *http* ]] && [[ $line != *www.openssl.org* ]]
        then
                echo $line > linetmp
                portww=$(cat linetmp | awk '{print $1}' | sed 's/\/tcp/,/g' | sed '$ s/.$//')
                #echo $portww
                echo -e "\n\nRunning Gobuster port: $portww ..."
                #echo $line
                #gobuster dir -u http://$1:$portww/ -k -t 30 -b "404,400" -w /usr/share/wordlists/dirb/common.txt >> temp1
                #gobuster dir -u $1 -t 100 -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt -x txt,php,html,htm,aspx -qz > temp1
                #gobuster dir -u http://$1:$portww/ -r -k -t 100 -w /usr/share/wordlists/dirbuster/directory-list-2.3-small.txt -x txt,php,html,aspx --wildcard >> temp1
                
                #wfuzz -t 200 --hc 404 -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt http://$1:$portww/FUZZ/ >> temp1

                gobuster dir -u http://$1:$portww/ -r -k -t 70 -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt -x txt,php,html,asp --wildcard --timeout 20s >> temp1
                #gobuster dir -u http://$1:$portww/ -k -t 100 -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt -x txt,php,html,asp --wildcard >> temp1

                echo -e "\nRunning WhatWeb port: $portww ..."
                #echo $line
                #whatweb $1:$portww --open-timeout 3 --read-timeout 11 -v > temp2
                whatweb $1:$portww -v > temp2

                if [ -e temp1 ] && [[ $line != *Websit* ]] && [[ $line != *www.openssl.org* ]]
                then
                        printf "\n\n------ DIRS $portww port------\n\n" >> results
                        cat temp1 >> results
                        rm temp1
                fi

                if [ -e temp2 ] && [[ $line != *Websit* ]] && [[ $line != *www.openssl.org* ]]
                then
                        printf "\n\n------ WEB $portww port------\n\n" >> results
                        cat temp2 >> results
                        rm temp2
                fi
        fi

done < results

if [ -e temp88 ]
then
        printf "\n\n------ Kerberos ------\n\n" >> results
        cat temp88 >> results
        rm temp88
fi

if [ -e tempsmb ]
then
        printf "\n\n------ SMB ------\n\n" >> results
        cat tempsmb >> results
        rm tempsmb
fi

if [ -e tempsnmp ]
then
        printf "\n\n------ SNMP ------\n\n" >> results
        cat tempsnmp >> results
        rm tempsnmp
fi

if [ -e rpcresult ]
then
        printf "\n\n------ RPC ------\n\n" >> results
        printf "SAVED IN FILE: rpcresult \n\n" >> results
fi

if [ -e tempsmtp ]
then
        printf "\n\n------ SMTP ------\n\n" >> results
        cat tempsmtp >> results
        rm tempsmtp
fi

if [ -e tempnfs ]
then
        printf "\n\n------ NFS ------\n\n" >> results
        cat tempnfs >> results
        rm tempnfs
fi

if [ -e tempnb ]
then
        printf "\n\n------ NetBIOS ------\n\n" >> results
        cat tempnb >> results
        rm tempnb
fi

if [ -e ldapresults ]
then
        #printf "\n\n------ LDAP ------\n\n" >> results
        cat ldapresults >> results
        rm ldapresults
fi

cat results

echo -e "\n\nRunning Nmap UDP...\n"
nmap -n --top-ports 2000 --reason --min-rate 3000 -sU $1 | tail -n +6 >> temp3

#nmap -n --top-ports 5000 --reason --min-rate 3000 -sU --open $1 | tail -n +6 >> temp3
#nmap -n --top-ports 15000 -sU --open --reason --min-rate 4000 $1 | tail -n +6 | head -n -1 >> temp3
printf "\n\n------ UDP ------\n\n" >> results

cat temp3
cat temp3 >> results

while read line
do
        if [[ $line == *open* ]] && [[ $line == 123/udp* ]]
        then
               #nmap -sU -sV --script "ntp* and (discovery or vuln) and not (dos or brute)" -p 123 $1 > tempntp
               nmap -sU -sV --script "ntp* and (discovery or vuln) and not (dos or brute)" --reason --min-rate 5000 -p 123 $1 | tail -n +5 | head -n -2  > tempntp
        #elif [[ $line == *open* ]] && [[ $line == 53/udp* ]]
                #DNS tz > tempdns
        fi
done < results

#if [ -e tempdns ]
#then
#        printf "\n------ DNS ------\n\n" >> results
#        cat tempdns >> results
#        rm tempdns
#fi

if [ -e tempntp ]
then
        printf "\n------ NTP ------\n\n" >> results
        echo -e "\n\n------ NTP ------\n"
        cat tempntp
        cat tempntp >> results
        rm tempntp
fi

rm temp3
#rm ldapresults
rm linetmp

#cat results

echo -e "\n\n\nRunning Detailed Nmap TCP...\n"
nmap -p$ports -sV -sC -n -Pn -reason --min-rate 5000 $1 | tail -n +5 | head -n -1 >> targeted
printf "\n\n------ Detailed NMAP ------\n\n" >> results
cat targeted
#cat temp4 >> results
#rm temp4


