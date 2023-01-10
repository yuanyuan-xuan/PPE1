#!/usr/bin/env bash

# pour lancer le script nous nous plaçons dans le repertoire PROJET/programmes/
#./script_chinois.sh ../URLS/chin.txt ../tableaux/tableau_chinois.html 


# Ce script bash prend en arguement un fichier .txt et le nom d'un tableau html, qu'il génère en sortie
# le fichier txt est une liste de 5- URLS sur Fast ou Street Food
# Vérifie l'encodage, et crée/ extrait les informations souhaités : dump, nombre d'occurence du motif, contexte


fichier_urls=$1 # le fichier d'URL en entrée
fichier_tableau=$2 # le fichier HTML en sortie

if [[ $# -ne 2 ]]
then
	echo "Ce programme demande exactement deux arguments."
	exit
fi

# street food en chinois
mot="快餐|速食|便餐"

echo $fichier_urls;
basename=$(basename -s .txt $fichier_urls)

echo "<html><body>" > $fichier_tableau
echo "<h2>Tableau $basename :</h2>" >> $fichier_tableau
echo "<br/>" >> $fichier_tableau
echo "<table aligne=\"center\"border=\"1px\"bordercolor=#ff964f>" >> $fichier_tableau
echo "<tr><th>ligne</th>
	<th>Code</th>
	<th>Encodage</th>
	<th>URL</th>
	<th>Dumps</th>
	<th>Aspirations</th>
	<th>Occurences</th>
	<th>Contexte</th>
	<th>Concordances</th></tr>" >> $fichier_tableau

lineno=1;
while read -r URL; do
	echo -e "\tURL : $URL";
	
	# la façon attendue, sans l'option -w de cURL
	code=$(curl -ILs $URL | grep -e "^HTTP/" | grep -Eo "[0-9]{3}" | tail -n 1)
	charset=$(curl -ILs $URL | grep -Eo "charset=(\w|-)+" | cut -d= -f2)

	# autre façon, avec l'option -w de cURL
	# code=$(curl -Ls -o /dev/null -w "%{http_code}" $URL)
	# charset=$(curl -ILs -o /dev/null -w "%{content_type}" $URL | grep -Eo "charset=(\w|-)+" | cut -d= -f2)

	echo -e "\tcode : $code";

	if [[ ! $charset ]]
	then
		echo -e "\tencodage non détecté, on prendra UTF-8 par défaut.";
		charset="UTF-8";
	else
		echo -e "\tencodage : $charset";
	fi

	if [[ $code -eq 200 ]]
	then
		dump=$(lynx -dump -nolist -assume_charset=$charset -display_charset=$charset $URL)
		if [[ $charset -ne "UTF-8" && -n "$dump" ]]
		then
			dump=$(echo $dump | iconv -f $charset -t UTF-8//IGNORE)
		fi
	else
		echo -e "\tcode différent de 200 utilisation d'un dump vide"
		dump=""
		charset=""
	fi
	
	# variable "$mot" always withing quotes 
	
	# dump 
	echo "$dump" > "../dumps-text/$basename-$lineno.txt"
		
	
	# number of instances of a word , insert in HTML Table 
	occurences=$(grep -E -o -i "$mot" ../dumps-text/$basename-$lineno.txt | wc -l)
	
	
	#concordances :construction concordance avec commande externe : ./ pour execution, si non confusion avec dossier 
	../programmes/concordance.sh ../dumps-text/$basename-$lineno.txt "$mot" > ../concordances/$basename-$lineno.html

	# aspiration
	charset=$(curl -Ls $URL -D - -o "../aspirations/$basename-$lineno.html" | grep -Eo "charset=(\w|-)+" | cut -d= -f2)
	
	# extraction des contextes
	contexte_temp=$(grep -E -A2 -B2 "$mot" ../dumps-text/$basename-$lineno.txt > ../contextes/$basename-$lineno.txt)
	context=(./seg_chin.py $contexte_temp)
	echo "$contexte"
	

	echo "<tr><td>$lineno</td>
	<td>$code</td>
	<td>$charset</td>
	<td><a href=\"$URL\">$URL</a></td>
	<td><a href=\"../dumps-text/$basename-$lineno.txt\">ch-$lineno</a></td>
	<td><a href=\"../aspirations/$basename-$lineno.html\">ch-$lineno</a></td>
	<td>$occurences</td>
	<td><a href=\"../contextes/$basename-$lineno.txt\">ch-$lineno</a></td>
	<td><a href=\"./../concordances/$basename-$lineno.html\">ch-$lineno</a></td>
	</tr>" >> $fichier_tableau
	
	echo -e "\t--------------------------------"
	lineno=$((lineno+1));
	
done < $fichier_urls
echo "</table>" >> $fichier_tableau
echo "</body></html>" >> $fichier_tableau
