function status = displayTwoDimClimatology(dataFile, figFile, varName, statTime, stopTime)

fd = netcdf(dataFile{1}, 'r');

var = fd{varName}(:);
lon = fd{'lon'}(:);
lat = fd{'lat'}(:);

var_clim = squeeze(simpleClimatology(var,1));
h = displayTwoDimData(lon, lat, var_clim');
title(h, [varName ', climatology']);
print(gcf, figFile, '-djpeg');
