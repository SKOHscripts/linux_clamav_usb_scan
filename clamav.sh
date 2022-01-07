#!/bin/bash
#######################################################################################
## A shell script, which uses the Clamav open-source antivirus engine to scan a folder.
## Copyright (C) Corentin Michel - All Rights Reserved
## Contact: corentin.michel@mailo.com [https://github.com/SKOHscripts]
#######################################################################################

rouge='\e[1;31m'
vert='\e[1;32m'
neutre='\e[0;m'

if [ "$UID" -eq "0" ]
then
    zenity --warning --height 80 --width 400 --title "EREUR" --text "Merci de lancez le script sans sudo : \n<b>./clamav.sh</b>\nVous devrez entrer le mot de passe root par la suite."
    exit
fi

which notify-send > /dev/null
if [ $? = 1 ]
then
	sudo apt install -y libnotify-bin
fi

which zenity > /dev/null
if [ $? = 1 ]
then
	sudo apt install -y zenity
fi

which clamav > /dev/null
if [ $? = 1 ]
then
	sudo apt install -y clamav clamav-daemon
fi

    echo ""
    echo -e -n "$vert [1/2]$rouge MISE A JOUR "
    for i in `seq 20 $COLUMNS`;
        do echo -n "."
    done
    echo -e " $neutre"
    zenity --info --width=300 --height=100 --text "You will be asked to enter your sudo password twice to update the virus database."
    notify-send -i system-software-update "Clamav" "Mises à jour"
    systemctl stop clamav-freshclam
    # Thp only way I found to counter the «ERROR: Can't open /var/log/clamav/freshclam.log in append mode» error was to execute these two following lines :
    sudo mkdir /var/log/clamav/
    sudo chown -R clamav:clamav /var/log/clamav/
    sudo freshclam
    systemctl start clamav-freshclam
    echo " "

    echo -e -n "$vert [2/2]$rouge SCAN "
    for i in `seq 13 $COLUMNS`;
        do echo -n "."
    done
    echo -e " $neutre"
    echo > log_clamav.txt
    zenity --info --width=300 --height=100 --text "Please select the folder you want to scan."
    notify-send -i system-software-update "Clamav" "Scan"
    inputStr=$(zenity --file-selection --directory "${HOME}")
    clamscan -r --remove --bell --log=log_clamav.txt $inputStr
    echo " "

    notify-send -i dialog-ok "Clamav" "Scan terminé"
