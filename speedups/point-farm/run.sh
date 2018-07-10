#!/bin/bash

#list of met masts
while read line;do
	id=`echo $line | awk -F " " '{print $1}'`
	lat=`echo $line | awk -F " " '{print $2}'`
	lon=`echo $line | awk -F " " '{print $3}'`
	hei=`echo $line | awk -F " " '{print $4}'`
	wrkid=`echo $line | awk -F " " '{print $5}'`
	echo "./point.farm.sh $id $lat $lon $hei $wrkid"
	./point.farm.sh $id $lat $lon $hei $wrkid
	if [ -f serieinput.nc ]; then
		rm serieinput.nc
	fi
	cp point.farm.$id.nc serieinput.nc
	cat ncdf2asc.ncl | /home/vortex/bin/ncl6 
	mv vortex_time_series.txt serie.$id.$lat.$lon.$hei.txt
	rm serieinput.nc
done < metmasts.txt
