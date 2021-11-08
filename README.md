# linux-clamav_usb_scan

[![support](
https://brianmacdonald.github.io/Ethonate/svg/eth-support-blue.svg)](
https://brianmacdonald.github.io/Ethonate/address#0xEDa4b087fac5faa86c43D0ab5EfCa7C525d475C2)

![GitHub](https://img.shields.io/github/license/M66B/FairEmail.svg)

<p>Un script shell qui utilise ClamAV®, un antivirus open-source, pour détecter les chevaux de Troie, les virus, les malwares et autres menaces.</p>

<p>Une initialisation permet de mettre à jour la base de donnée régulièrement améliorée par la communauté. Le script va ensuite scanner le dossier /media/, dans lequel se trouvent les clefs USB et autre disques durs externes.</a>

Pour lancer le script, ne pas oublier d'autoriser l'exécution : <br/>`chmod +x ./clamav.sh`

Puis se placer dans le dossier et exécuter le script : <br/>`./clamav.sh`

Et voilà, après tout se fait tout seul. Le résultat du scan sera sauvegardé dans un fichier log `log_clamav.txt`.

Une prochaine mise à jour permettra de choisir le dossier à scanner.

---

<p>A shell script that allows to do a complete maintenance of the Linux system (under Ubuntu). Useful <p>A shell script that uses ClamAV®, an open-source antivirus, to detect Trojans, viruses, malware and other threats.</p>

<p>An initialization is used to update the database regularly enhanced by the community. The script will then scan the /media/ folder, where USB sticks and other external hard drives are located.</a>

To launch the script, don't forget to authorize the execution : <br/>`chmod +x ./clamav.sh`

Then place yourself in the folder and execute the script: <br/>`./clamav.sh`

And that's it, then everything is done by itself. The scan result will be saved in a log file `log_clamav.txt`.

A future update will allow you to choose the folder to scan.

``` bash
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
	sudo apt install -y clamav
fi

    echo ""
    echo -e -n "$vert [1/7]$rouge MISE A JOUR "
    for i in `seq 20 $COLUMNS`;
        do echo -n "."
    done
    echo -e " $neutre"
    notify-send -i system-software-update "Clamav" "Mises à jour"
    sudo systemctl stop clamav-freshclam
    sudo freshclam
    sudo systemctl start clamav-freshclam
    echo " "

    echo -e -n "$vert [2/7]$rouge SCAN "
    for i in `seq 13 $COLUMNS`;
        do echo -n "."
    done
    echo -e " $neutre"
    notify-send -i system-software-update "Clamav" "Scan"
    clamscan -r -i --remove --bell --log=log_clamav.txt /media/
    echo " "

    notify-send -i dialog-ok "Clamav" "Scan terminé"
```
## License

Copyright &copy; 2020-2021 Corentin Michel. All rights reserved.

[GNU General Public License version 3](https://www.gnu.org/licenses/gpl.txt)

> This script is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

> This script is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

