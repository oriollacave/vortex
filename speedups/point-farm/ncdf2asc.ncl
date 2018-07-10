load "/home/vortex/lib/ncarg/nclscripts/contributed.ncl"

f = addfile ("serieinput.nc", "r")

time = f->time

U    = f->U(:,0,0,0)
V    = f->V(:,0,0,0)
T    = f->T(:,0,0,0)
hgt  = f->HGT(:,0,0)



ntime = dimsizes(time)
matrix = new ((/ntime,3/),float)

date = ut_calendar (time,2)
temp = ut_calendar (time,0)
temphour = temp (:,3) 
hour = floattointeger(temphour)

index = ind ((date.eq.20001231).and.(hour.eq.15))

if (.not.ismissing(index)) then
hour (index(1)) = 16
end if


r2d = 45.0/atan(1.0)
D   = atan2(U,V)* r2d + 180
M   = sqrt(U^2+V^2)





vector = new(ntime,string)

;check whether time zone is #.5;
zonef=0
check = zonef - doubletoint(zonef)
if (check.ne.0) then
do i = 0, ntime-1
vector(i) = sprintf("%8.0f", date(i)) + " " + sprinti("%0.2i", hour(i)) +"30 " + sprintf("%6.1f", M(i)) + " " + sprintf("%6.0f", D(i)) + sprintf("%7.1f", T(i)) 
end do
else
do i = 0, ntime-1
vector(i) = sprintf("%8.0f", date(i)) + " " + sprinti("%0.2i", hour(i)) +"00 " + sprintf("%6.1f", M(i)) + " " + sprintf("%6.0f", D(i)) + sprintf("%7.1f", T(i)) 
end do
end if


system("/bin/rm -f vortex_time_series.txt")
asciiwrite("vortex_time_series.txt",vector)
