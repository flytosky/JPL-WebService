function status = displayTwoDimClimatology(dataFile, figFile)

%fn = '/home/zhai/cmip5/ukmo/hadgem2-a/ts_Amon_HadGEM2-A_amip_r1i1p1_197809-200811.nc';
fd = netcdf(dataFile, 'r');

ts = fd{'ts'}(:);
lon = fd{'lon'}(:);
lat = fd{'lat'}(:);

ts_clim = squeeze(simpleClimatology(ts,1));
h = displayTwoDimData(lon, lat, ts_clim');
print(gcf, figFile, '-djpeg');
