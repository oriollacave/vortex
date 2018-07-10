netcdf base {
dimensions:
	lon = 3 ;
	lat = 3 ;
variables:
	double lon(lon) ;
		lon:long_name = "longitude" ;
		lon:units = "degrees_east" ;
		lon:standard_name = "longitude" ;
	double lat(lat) ;
		lat:long_name = "latitude" ;
		lat:units = "degrees_north" ;
		lat:standard_name = "latitude" ;
	float var1(lat, lon) ;

// global attributes:
		:CDI = "Climate Data Interface version 1.3.0" ;
		:Conventions = "CF-1.0" ;
		:history = "Wed Apr 15 11:55:31 2009: cdo -r -f nc const,0,r1x1 base.nc" ;
		:CDO = "Climate Data Operators version 1.3.0 (http://www.mpimet.mpg.de/cdo)" ;
data:

 lon = XXX ;

 lat = YYY ;

 var1 =
  0, 0 ,0 ;
}
