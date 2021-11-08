#!/bin/bash

rouge='\e[1;31m'
vert='\e[1;33m'
bleu='\e[1;34m'
violet='\e[1;35m'
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
    notify-send -i system-software-update "Clamav" "Mises à jour"
    systemctl stop clamav-freshclam
    sudo freshclam
    systemctl start clamav-freshclam
    echo " "

    echo -e -n "$vert [2/2]$rouge SCAN "
    for i in `seq 13 $COLUMNS`;
        do echo -n "."
    done
    echo -e " $neutre"
    echo > log_clamav.txt
    notify-send -i system-software-update "Clamav" "Scan"
    inputStr=$(zenity --file-selection --directory "${HOME}")
    clamscan -r --remove --bell --log=log_clamav.txt $inputStr
    echo " "

    notify-send -i dialog-ok "Clamav" "Scan terminé"
