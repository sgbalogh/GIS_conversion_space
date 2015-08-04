echo "" 
echo "######## WARNING!!! ########"
echo ""
echo "This will DELETE everything in the staging directory,"
echo "except files in the 'input_zipped_shapefiles' directory!"
echo ""
echo "You sure you want to do this??"
perform=false
while true; do
    read -p "[Y/n] > " yn
    case $yn in
        [Yy]* ) perform=true; break;;
        [Nn]* ) perform=false; break;;
        * ) echo "Please answer yes or no next time..."; break;
    esac
done

if [ $perform = true ]; then
	cd /home/ubuntu/staging_area
	rm -R ./input_shp_to_WGS84/*
	rm -R ./input_shp_to_SQL/*
	rm -R ./input_SQL_to_postgres/*
	rm -R ./output_shp_to_SQL/*
	rm -R ./output_shp_to_WGS84/*
fi
