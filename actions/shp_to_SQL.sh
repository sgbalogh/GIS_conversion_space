inputdirtoSQL="/home/ubuntu/staging_area/input_shp_to_SQL"
outputdirtoSQL="/home/ubuntu/staging_area/output_shp_to_SQL"
cd $inputdirtoSQL
for folder in *; do
	if ! [[ $folder == *"."* ]]
	then
		cd "$inputdirtoSQL/$folder"
		pwd
		for f in $inputdirtoSQL/$folder/*.shp
			do
    		shp2pgsql -I -s 4326 $f `basename $f .shp` > $outputdirtoSQL/`basename $f .shp`.sql
    		if [ "$?" != "0" ]; then
    			shp2pgsql -I -s 4326 -W "latin1" $f `basename $f .shp` > $outputdirtoSQL/`basename $f .shp`.sql
			fi
		done
	fi
done
cd /home/ubuntu/staging_area/output_shp_to_SQL
for asset in *; do
	cp "./$asset" ../input_SQL_to_postgres
done