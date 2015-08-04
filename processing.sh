#Interactivity
stagestatus="ZIP"
renamestatus=false
printf '\n\n'
echo "########################################"
echo "       NYU SDR Processing Script"
echo "########################################"
printf '\n\n'

echo "What stage are your files at right now?"
echo "(Please type exactly as the option appears)"
printf '\n\n'
while true; do
    read -p "[ZIP], [SHP], [WGS84], or [SQL]? > " stage
    case $stage in
        ZIP* ) stagestatus="ZIP"; break;;
        SHP* ) stagestatus="SHP"; break;;
        WGS84* ) stagestatus="WGS84"; break;;
        SQL* ) stagestatus="SQL"; break;;
        * ) echo "Please answer yes or no next time..."; break;
    esac
done
echo ""

if [ $stagestatus = "SHP" ] || [ $stagestatus = "ZIP" ]; then
echo "Do you want to rename individual files?"
echo "(Currently only supported when beginning from ZIP or SHP, before reprojection)"
while true; do
    read -p "[Y/n] > " yn
    case $yn in
        [Yy]* ) renamestatus=true; break;;
        [Nn]* ) renamestatus=false; break;;
        * ) echo "Please answer yes or no next time..."; break;
    esac
done
echo ""
fi

echo "************************************ READ CAREFULLY: ***********************************"
echo "You are about to run this script starting with $stagestatus files, does that sound right?"

while true; do
    read -p "[Y/n] > " yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) echo "Then run this script again!"; exit;;
        * ) echo "Please answer yes or no next time..."; break;
    esac
done


#Unzip the files
if [ $stagestatus = "ZIP" ]; then
cd ./input_zipped_shapefiles
for zip in *.zip; do
	mkdir "/home/ubuntu/staging_area/input_shp_to_WGS84/${zip%.*}"
	unzip "$zip" -d "/home/ubuntu/staging_area/input_shp_to_WGS84/${zip%.*}"
done
fi

if [ $renamestatus = true ]; then
cd /home/ubuntu/staging_area/input_shp_to_WGS84/
for folder in *; do
	cd ./$folder
	for shp in *.shp; do
		shape=$shp
		shape=${shape%.*}
	done
	echo ""
	echo ""
	echo "*****************************************"
	echo "The shape name is currently: $shape."
	echo ""
	echo "What do you want to rename that to?"
    	read -p "Type in name: > " newshape
    	echo ""
	    echo "OK. Renaming everything $newshape..."
	    echo ""
	    for asset in *; do
	    	filename=$(basename "$asset")
	    	baseasset="${filename%.*}"
	    	extasset="${filename##*.}"
	    	if [ $extasset = "xml" ] || [ $extasset = "XML" ]; then
	    		mv $asset $newshape.shp.$extasset
	    	else
	    		mv $asset $newshape.$extasset
	    	fi
	    	
	    done
	    
	cd ../
	echo "Renaming containing folder to $newshape."
	mv $folder $newshape
done
fi

#Reproject to WGS 1984 (if the source shapefile does not already have that CRS)

if [ $stagestatus = "SHP" ] || [ $stagestatus = "ZIP" ]; then
activedir="/home/ubuntu/staging_area/input_shp_to_WGS84"
cd $activedir
for folder in *; do
	destdir="/home/ubuntu/staging_area/output_shp_to_WGS84/$folder"
	if ! [[ $folder == *".zip" ]]
	then
    	mkdir "/home/ubuntu/staging_area/output_shp_to_WGS84/$folder"
    	cd $folder
		for i in *.shp; do
  			ogr2ogr -t_srs EPSG:4326 "$destdir/${i%.*}.shp" "$i"
		done
		cd ../
	fi
done
cd /home/ubuntu/staging_area/output_shp_to_WGS84
for asset in *; do
	cp -R "./$asset" ../input_shp_to_SQL
done
cd $activedir
fi

#Converts reprojected shapefile to SQL

if [ $stagestatus = "WGS84" ] || [ $stagestatus = "SHP" ] || [ $stagestatus = "ZIP" ]; then
inputdirtoSQL="/home/ubuntu/staging_area/input_shp_to_SQL"
outputdirtoSQL="/home/ubuntu/staging_area/output_shp_to_SQL"
cd $inputdirtoSQL
for folder in *; do
	if ! [[ $folder == *"."* ]]
	then
		cd "$inputdirtoSQL/$folder"
		items="$(ls -1 | wc -l)"
		if [ $items != "0" ]; then
			for f in $inputdirtoSQL/$folder/*.shp
				do
    			shp2pgsql -I -s 4326 $f `basename $f .shp` > $outputdirtoSQL/`basename $f .shp`.sql
    			if [ "$?" != "0" ]; then
    				shp2pgsql -I -s 4326 -W "latin1" $f `basename $f .shp` > $outputdirtoSQL/`basename $f .shp`.sql
				fi
			done
		fi
	fi
done
cd /home/ubuntu/staging_area/output_shp_to_SQL
for asset in *; do
	cp "./$asset" ../input_SQL_to_postgres
done
fi

#Uploads SQL files to PostGIS database, dependent on user input

echo ""
echo ""

cd /home/ubuntu/staging_area/output_shp_to_SQL
counter=0
for f in *.sql
do
    counter=$((counter + 1))
done

uploadSQL=false

echo "******************"
echo "ANSWER CAREFULLY!:"
echo ""
echo "Do you want to upload these SQL files to the PostGIS database?"
echo "There are currently $counter SQL file(s) staged for upload." 
echo ""
while true; do
    read -p "[Y/n] > " yn
    case $yn in
        [Yy]* ) uploadSQL=true; break;;
        [Nn]* ) break;;
        * ) echo "Please answer yes or no next time..."; break;
    esac
done

if [ $uploadSQL = true ]; then
	for f in *.sql
	do
    	psql --host MYHOST.COM --port 5432 --username USER --dbname DATABASE -w -f $f
	done
else
	echo "Nothing was uploaded to the SDR."
fi
