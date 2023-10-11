#!/bin/bash
#

# Join weather on path
if [[ ! -f  /usr/bin/weather ]]; then
  sudo ln -s $(pwd)/weather.sh /usr/bin/weather
fi



#PathProject="$(pwd)/location.txt"
PathProject="$(sudo find / type -depth -name Weather 2> /dev/null)"
PathProject+="/location.txt"

#the file is created where localization will be
#User can change their location if he deletes this file.

if [[ ! -e $PathProject ]]; then
  echo " Introduce tu localización sin acentos "
  read -r location
  
  location=${location// /%20}

  #Creates the file with the city name.
  echo "$location" > "$PathProject"

#If the file exist the variable location will continue to have value and will be passed to the URL
else
  
  location=$(cat $PathProject | head -n 1)

fi

echo $location

#In this section the curl is Cleaned. 
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


#An image is selected according to the weather
imagenes="./days-images/*"

for imagen in $imagenes
do

#In this secctions the .png extension is cleaned.
  nombre=$(basename $imagen .png)

  if [[ $day == $nombre ]]; then
     
    notificacion=$(notify-send -i $imagen "weather in $city" "<b>T.Min     T.Actual     T.Max</b>\n $mint           $temp             $maxt")
    echo "$notificacion"
  fi
done

#The Temp file is deleted.
rm ~/temp.txt

#skyblue limpiar las salidas de consola

echo "$PathProject"
