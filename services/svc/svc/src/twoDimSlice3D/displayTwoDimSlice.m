function status = displayTwoDimSlice(dataFile, figFile, varName, startTime, stopTime, thisPlev, lonRange, latRange, monthIdx, outputFile)
%
% This function extracts relevant data from the data file list according
% the specified temporal range [startTime, stopTime], longitude & latitude range, and seasonal months in a year
% of a 3-D field at the specified level.
%
% Input:
%   dataFile	-- a list of relevant data files
%   figFile	-- the name of the output file for storing the figure to be displayed
%   varName	-- the physical variable of interest, or to be displayed
%   startTime	-- the start time of the temporal window over which the climatology is computed
%   stopTime	-- the stop time of the temporal window over which the climatology is computed
%   thisPlev	-- pressure level to be displayed, a linear interpolation is used based on the log(pressure)		
%   lonRnage	-- an optional argument to specify box boundary along longitude
%   latRnage	-- an optional argument to specify box boundary along latitude
%   monthIdx	-- an optional argument to specify months within a year, which is useful for computing climatology for a specific season.
%   outputFile	-- an optional argument to specify the netcdf data filename for outputing 
%
% Output:
%   status	-- a status flag, 0 = okay, -1 something is not right
%
% Author: Chengxing Zhai
%
% Revision history:
%   2013/03/25:	Initial version, cz
%

if nargin < 10
  outputFile = [];
end

if nargin < 9
  monthIdx = 1:12;
end

if nargin < 8
  latRange = [-90, 90];
end

if nargin < 7
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
plev = [];

for fileI = 1:nFiles
  fd = netcdf(dataFile{fileI}, 'r');

  varinfo = ncvar(fd);

  plevVarName = [];
  for ii = 1:length(varinfo)
    varNameList{ii} = ncname(varinfo{ii});
    if strcmp('plev', varNameList{ii})
      plevVarName = 'plev';
      break;
    elseif strcmp('lev', varNameList{ii})
      plevVarName = 'lev';
    end
  end
  if isempty(plevVarName)
    error('No variable for pressure level found!');
  end

  if isempty(monthlyData)
    lon = fd{'lon'}(:);
    lat = fd{'lat'}(:);
    plev = readPressureLevels(fd, plevVarName);
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

    [p_idx, p_alphas] = linearInterpHelper(thisPlev, plev, 'log'); % get the layers relevant to the specified pressure level
    monthlyData = nan(nMonths, nLat, nLon);
  end

  v = fd{varName}(:);
  if ~isempty(fd{varName}.missing_value)
    v(abs(v - fd{varName}.missing_value) < 1) = NaN;
  end
  v_units = fd{varName}.units;
  v_units = adjustUnits(v_units, varName);
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
  monthlyData(monthIdx1:monthIdx2, :, :) = squeeze(v(idx2Data_start:idx2Data_stop, p_idx(1), latIdx,lonIdx) * p_alphas(1));
  for pIdx = 2:length(p_idx)
    monthlyData(monthIdx1:monthIdx2, :, :) = monthlyData(monthIdx1:monthIdx2, :, :) + squeeze(v(idx2Data_start:idx2Data_stop, p_idx(pIdx), latIdx,lonIdx) * p_alphas(pIdx));
  end
  long_name = fd{varName}.long_name;
  ncclose(fd);
  clear v;
end

% We now determine the relevant months within a year using monthIdx and start month

monthIdxAdj = mod(monthIdx - startTime.month, 12) + 1;

var_clim = squeeze(simpleClimatology(monthlyData,1, monthIdxAdj));
[h, cb] = displayTwoDimData(lon, lat, var_clim');
plev_units = 'hPa';
if strcmp(varName, 'ot') || strcmp(varName, 'os') 
  plev_units = 'dbar';
end
title(h, [varName ', at ' num2str(round(thisPlev/100)) plev_units ', ' date2Str(startTime, '/') '-' date2Str(stopTime, '/') ' climatology (' v_units '), ' seasonStr(monthIdx)]);
set(get(cb,'xlabel'), 'string', [long_name '(' v_units ')'], 'FontSize', 16);
print(gcf, figFile, '-djpeg');

data.dimNames = {'latitude', 'longitude'};
data.nDim = 2;
data.dimSize = [length(lat), length(lon)];
data.dimVars = {lat, lon};
data.var = var_clim;
data.varName = varName;
data.dimVarUnits = {'degree_north', 'degree_east'};
data.varUnits = v_units;
data.varLongName = long_name;

status = 0;

if ~isempty(outputFile);
  status = storeDataInNetCDF(data, outputFile);
end
