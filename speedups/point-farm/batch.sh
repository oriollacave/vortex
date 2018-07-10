#!/bin/bash
rm ./metmasts.txt
rm ./point*.nc
rm site.nc
while read site;do
	cp sites/$site/metmasts.txt .
	./run.sh	
	mkdir -p sites/$site/series
	mv serie*.txt sites/$site/series/
	rm ./metmasts.txt
	rm ./point*.nc
	rm site.nc
done < sites.txt
