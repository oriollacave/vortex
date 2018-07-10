#!/bin/sh
for site in `ls ../../series/`; do
	if [ -d ../../series/$site ]; then 
		Rscript tablesFromSeries.R $site 
		mkdir -p results/$site
		mv ./*.png results/$site
		mv ./*.asc results/$site
		mv ./*.pdf results/$site
	fi
done
