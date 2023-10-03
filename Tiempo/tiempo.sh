#!/bin/bash
#

#TODO yellow  ---> Cambiar lo de location y meterlo dentro de la carpeta del proyecto (hace falta crearla)


#orange ¿Path definitivo?
#
# lo metemos en el path 
if [[ ! -f  /usr/bin/tiempo ]]; then
  sudo ln -s $(pwd)/tiempo.sh /usr/bin/tiempo
fi

#orange ¿location definitiva? // mejor dentro de la carpeta del proyecto
PathProject="$HOME/location.txt"


#creamos un archivo de texto donde albergaremos la localización
#para que el usuario pueda cambiar la localización cuando borre dicho archivo.

if [[ ! -e $PathProject ]]; then
  echo " Introduce tu localización sin acentos "
  read -r location
  
  location=${location// /%20}

  #crea el fichero con el nombre de la ciudad 
  echo "$location" > "$PathProject"

#si el fichero ya existe la variable location seguirá teniendo valor y se pasará  la URL
else
  
  location=$(cat $PathProject | head -n 1)

fi

echo $location

curl -s --request GET \
	--url "https://visual-crossing-weather.p.rapidapi.com/forecast?aggregateHours=24&location=$location&contentType=json&unitGroup=metric&shortColumnNames=0" \
	--header 'X-RapidAPI-Host: visual-crossing-weather.p.rapidapi.com' \
	--header 'X-RapidAPI-Key: 5589de5906msh090fa4399116c0ap13f4e4jsne21c413bce18' > ~/temp.txt

temp=$(cat ~/temp.txt |tr "{" "\n" | tr "}" "\n"| grep $(date +"%Y-%m-%d") | tr "," "\n" | tr "\"" " "| grep temp | tr ":" " " | awk '{print $2}'| sed -n '{1p}' | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
echo "$temp"

mint=$(cat ~/temp.txt |tr "{" "\n" | tr "}" "\n"| grep $(date +"%Y-%m-%d") | tr "," "\n" | tr "\"" " "| grep mint | tr ":" " " | awk '{print $2}'| sed -n '{1p}' | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
echo "$mint"

maxt=$(cat ~/temp.txt |tr "{" "\n" | tr "}" "\n"| grep $(date +"%Y-%m-%d") | tr "," "\n" | tr "\"" " "| grep maxt | awk -F ":" '{printf $2}'| sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
echo "$maxt"

city=$(cat ~/temp.txt |tr "{" "\n" | tr "}" "\n"| tr "," "\n"| tr "\"" " " | grep address | sed -n '3p' | awk -F ":" '{print $2}'|sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
echo "$city"

day=$(cat ~/temp.txt | tr "," "\n" | grep icon | tr "\"" " " | tr ":" " " | awk '{print $2}' | sed -n '1p'| sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
echo "$day"

imagenes="/home/kali/Downloads/days-images/*"

for imagen in $imagenes
do


#orange PROBANDO EN HACER UN PATH CON LA carpeta
#
#PathImagenes= $(find / -type d -name Tiempo 2> /dev/null)

#limpiamos la extensión .png
  nombre=$(basename $imagen .png)

  if [[ $day == $nombre ]]; then
     
    echo "$imagen"  67   │ #TODO DONE ponerlo en crontab o ponerlo en el path para hacer un comando de ello

    notificacion=$(notify-send -i $imagen "Tiempo en $city" "<b>T.Min     T.Actual     T.Max</b>\n $mint           $temp             $maxt")
    echo "$notificacion"
  fi
done

rm ~/temp.txt

#skyblue limpiar las salidas de consola
#green ponerlo en crontab o ponerlo en el path para hacer un comando de ello
#green poder poner la ciudad en la que está y sustituir los espacios para meterlo en la URL
#TODO orange subirlo a github, cambiar la ruta de location y de las imagenes
#TODO orange probarlo en otro pc


