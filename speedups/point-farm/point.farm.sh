#!/bin/sh

id=$1
lat=$2
lon=$3
height=$4
wrkid="${5%\\n}"
newnum=`echo $wrkid | awk '{printf "%04i\n", int($1/1000)}'`

delta=0.0004
lo1=$(echo "$lon-$delta" |bc)
la1=$(echo "$lat-$delta" |bc)
lo2=$(echo "$lon+$delta" |bc)
la2=$(echo "$lat+$delta" |bc)

xxx="$lo1,$lon,$lo2"
yyy="$la1,$lat,$la2"

##generation of a grid in a netCDF file
cat base.cdf | sed 's/XXX/'$xxx'/' | sed 's/YYY/'$yyy'/' > site.cdf
ncgen -o site.nc site.cdf


#############################################################

rm -r -f temp/
mkdir temp
for file in `ls /home/vortex/runs/$newnum/$wrkid/*/wrfout_d04*nc`; do
date=`echo $file | awk -F "/" '{print $NF}' | awk -F "_" '{print $3}'`
cdo2 -s intlevel,$height -selindexbox,2,2,2,2 -remapdis,site.nc $file temp/point-$date.nc

done

rm -f point.farm.$id.nc
cdo2 -s cat temp/point*nc point.farm.$id.nc

#fix 360 degrees issue
mv point.farm.$id.nc foo.nc
echo 'f=addfile("foo.nc","w")
lon = f->lon
if (lon.gt.180);then
lon=lon-360.
end if
f->lon=(/lon/)' | ncl > log 
rm -f log
mv foo.nc point.farm.$id.nc


rm -rf temp site.nc site.cdf foo.nc

