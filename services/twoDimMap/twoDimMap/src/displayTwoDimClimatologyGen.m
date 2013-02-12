function status = displayTwoDimClimatologyGen(dataFile, figFile, varName, startTime, stopTime, lonRange, latRange, monthIdx)
%
% This function extracts relevant data from the data file list according
% the specified temporal range [startTime, stopTime]
%
% Input:
%   dataFile	-- a list of relevant data files
%   figFile	-- the name of the output file for storing the figure to be displayed
%   varName	-- the physical variable of interest, or to be displayed
%   startTime	-- the start time of the temporal window over which the climatology is computed
%   stopTime	-- the stop time of the temporal window over which the climatology is computed
%   lonRnage	-- an optional argument to specify box boundary along longitude
%   latRnage	-- an optional argument to specify box boundary along latitude
%   monthIdx	-- an optional argument to specify months within a year, which is useful for computing climatology for a specific season.
%
% Output:
%   status	-- a status flag, 0 = okay, -1 something is not right
%
% Author: Chengxing Zhai
%
% Revision history:
%   2012/12/10:	Initial version, cz
%   2012/02/06: Added more arguments to facilitate a customized regional and seasonal climatology
%

if nargin < 8
  monthIdx = 1:12;
end

if nargin < 7
  latRange = [-90, 90];
end

if nargin < 6
  lonRange = [0, 360];
end 

nMonths = numberOfMonths(startTime, stopTime);

printf('number of month = %d\n', nMonths);

monthlyData = [];

nFiles = length(dataFile);

printf('number of files = %d\n', nFiles);
v = [];
lon = [];
lat = [];

for fileI = 1:nFiles
  fd = netcdf(dataFile{fileI}, 'r');

  if isempty(monthlyData)
    lon = fd{'lon'}(:);
    lat = fd{'lat'}(:);

    latIdx = find(lat <= latRange(2) & lat >= latRange(1));
    nLat = length(latIdx);
    lat = lat(latIdx);

    if lonRange(1) >= 0
      lonIdx = find(lon <= lonRange(2) & lon >= lonRange(1));
      nLon = length(lonIdx);
      lon = lon(lonIdx);
    else
      lon_neg = lon - 360;
      if lonRange(2) < 0
        lonIdx = find(lon_neg <= lonRange(2) & lon_neg >= lonRange(1));
        nLon = length(lonIdx);
        lon = lon_neg(lonIdx);
      else
        lonIdx = find(lon <= lonRange(2));
        lonIdx_neg = find(lon_neg >= lonRange(1));
        lonIdx = [lonIdx_neg; lonIdx];
        lon = [lon_neg(lonIdx_neg); lon(lonIdx)];
        nLon = length(lonIdx);
      end
    end

    monthlyData = nan(nMonths, nLat, nLon);
  end

  v = fd{varName}(:);
  v_units = fd{varName}.units;
  [startTime_thisFile, stopTime_thisFile] = parseDateInFileName(dataFile{fileI});

  monthIdx1 = numberOfMonths(startTime, startTime_thisFile);
  monthIdx2 = numberOfMonths(startTime, stopTime_thisFile);

  nMonths_thisFile = size(v,1);

  idx2Data_start = 1;
  idx2Data_stop = nMonths_thisFile;

  if monthIdx1 <= 1
    idx2Data_start = 1 + (1 - monthIdx1);
    monthIdx1 = 1;
  end

  if monthIdx2 >= nMonths
    idx2Data_stop = idx2Data_stop - (monthIdx2 - nMonths);
    monthIdx2 = nMonths;
  end

  disp(size(v));
  disp(latIdx);
  disp(lonIdx);
  monthlyData(monthIdx1:monthIdx2, :, :) = v(idx2Data_start:idx2Data_stop,latIdx,lonIdx);
end

var_clim = squeeze(simpleClimatology(monthlyData,1));
h = displayTwoDimData(lon, lat, var_clim');
title(h, [varName ', ' date2Str(startTime) '-' date2Str(stopTime) ' climatology (' v_units '), ' seasonStr(monthIdx)]);
print(gcf, figFile, '-djpeg');
