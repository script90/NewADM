#!/bin/bash
declare -A cor=( [0]="\033[1;37m" [1]="\033[1;34m" [2]="\033[1;31m" [3]="\033[1;33m" [4]="\033[1;32m" )
SCPdir="/etc/newadm" && [[ ! -d ${SCPdir} ]] && exit 1
SCPfrm="/etc/ger-frm" && [[ ! -d ${SCPfrm} ]] && exit
SCPinst="/etc/ger-inst" && [[ ! -d ${SCPinst} ]] && exit
SCPidioma="${SCPdir}/idioma" && [[ ! -e ${SCPidioma} ]] && touch ${SCPidioma}
mportas () {
unset portas
portas_var=$(lsof -V -i tcp -P -n | grep -v "ESTABLISHED" |grep -v "COMMAND" | grep "LISTEN")
while read port; do
var1=$(echo $port | awk '{print $1}') && var2=$(echo $port | awk '{print $9}' | awk -F ":" '{print $2}')
[[ "$(echo -e $portas|grep "$var1 $var2")" ]] || portas+="$var1 $var2\n"
done <<< "$portas_var"
i=1
echo -e "$portas"
}
ssl_stunel () {
[[ $(mportas|grep stunnel4|head -1) ]] && {
msg -ama " $(fun_trans "Parando Stunnel")"
msg -bar
fun_bar "apt-get purge stunnel4 -y"
msg -bar
msg -ama " $(fun_trans "Parado Com Sucesso!")"
msg -bar
return 0
}
msg -azu " $(fun_trans "SSL Stunnel")"
msg -bar
msg -ama " $(fun_trans "Escolha a Porta Para o SSL. Exemplo: 443")"
msg -bar
    while true; do
    read -p " Listen-SSL: " SSLPORT
    [[ $(mportas|grep -w "$SSLPORT") ]] || break
    echo -e "\033[1;33m $(fun_trans "esta Porta Ja esta em Uso")\033[0m"
    unset SSLPORT
    done
msg -bar
msg -ama " $(fun_trans "Instalando SSL")"
msg -bar
fun_bar "apt-get install stunnel4 -y"
echo -e "cert = /etc/stunnel/stunnel.pem\nclient = no\nsocket = a:SO_REUSEADDR=1\nsocket = l:TCP_NODELAY=1\nsocket = r:TCP_NODELAY=1\n\n[stunnel]\nconnect = 127.0.0.1:22\naccept = ${SSLPORT}" > /etc/stunnel/stunnel.conf
openssl genrsa -out key.pem 2048 > /dev/null 2>&1
(echo BR; echo BR; echo BR; echo BR; echo BR; echo BR; echo BR)|openssl req -new -x509 -key key.pem -out cert.pem -days 1095 > /dev/null 2>&1
cat key.pem cert.pem >> /etc/stunnel/stunnel.pem
sed -i 's/ENABLED=0/ENABLED=1/g' /etc/default/stunnel4
service stunnel4 restart > /dev/null 2>&1
/etc/init.d/stunnel4 restart > /dev/null 2>&1
msg -bar
msg -ama " $(fun_trans "INSTALADO COM SUCESSO")"
msg -bar
return 0
}
ssl_stunel
