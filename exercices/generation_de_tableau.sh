#!/usr/bin/env bash


fichier_urls=$1 # le fichier d'URL en entrée contenant les urlS
#fichier_tableau=$2 # le fichier HTML en sortie

if [[ $# -ne 1 ]]
then
        echo "Ce programme demande exactement un argument."
        exit
fi

echo "<header>
         <meta charset=\"utf-8\"/>
         <title>TABlEAU DES URLS</title>
      </header>

      <body>
         <table border=\"10px\">" >> tableau.html

         echo "<tr><th>ligne</th>
                   <th>Code</th>
                   <th>url</th>" >>tableau.html

i=0 #cela permet d'ajouter la numérotation au début

while read line #condition while = read line
        do
        echo "<tr><td>$((i=i+1))<td>$line</td></td></tr>" >> tableau.html
        code=$(curl -ILs $fichier_urls | grep -e "^HTTP/" | grep -Eo "[0-9]{3}" |tail -n 1)
        echo -e "\tcode : $code" >>tableau.html
        done < $fichier_urls

       
echo "</table></body></html>" >> tableau.html
