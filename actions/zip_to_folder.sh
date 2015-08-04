cd /home/ubuntu/staging_area/input_zipped_shapefiles
pwd
for zip in *.zip; do
	mkdir "/home/ubuntu/staging_area/input_shp_to_WGS84/${zip%.*}"
	unzip "$zip" -d "/home/ubuntu/staging_area/input_shp_to_WGS84/${zip%.*}"
done