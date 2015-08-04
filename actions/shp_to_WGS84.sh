activedir="/home/ubuntu/staging_area/input_shp_to_WGS84"
cd $activedir
ls
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