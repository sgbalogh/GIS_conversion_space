cd /home/ubuntu/staging_area/output_shp_to_SQL
counter=0
for f in *.sql
do
    counter=$((counter + 1))
done

uploadSQL=false
while true; do
    read -p "ANSWER CAREFULLY: Do you want to upload these SQL files to the PostGIS database? There are currently $counter SQL file(s) staged for upload. [Y/n] " yn
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
