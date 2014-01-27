function status = displayThreeDimZonalMean(dataFile, figFile, varName, startTime, stopTime, latRange, plevRange, monthIdx, outputFile)
%
% This function extracts relevant data from the data file list according
% the specified temporal range [startTime, stopTime], longitude and latitude ranges
%
% Input:
%   dataFile	-- a list of relevant data files
%   figFile	-- the name of the output file for storing the figure to be displayed
%   varName	-- the physical variable of interest, or to be displayed
%   startTime	-- the start time of the temporal window over which the climatology is computed
%   stopTime	-- the stop time of the temporal window over which the climatology is computed
%   latRnage	-- an optional argument to specify box boundary along latitude
%   plevRnage	-- an optional argument to specify pressule levels for alitutde range
%   monthIdx	-- an optional argument to specify months within a year, which is useful for computing climatology for a specific season.
%   outputFile	-- an optional argument to specify output file for storing the plotting data in netcdf format
%
% Output:
%   status	-- a status flag, 0 = okay, -1 something is not right
%
% Author: Chengxing Zhai
%
% Revision history:
%   2012/03/25:	Initial version, cz
%   2013/06/14:	add capability of outputing data file
%
status = -1;

if nargin < 9
  outputFile = [];
end

if nargin < 8
  monthIdx = 1:12;
end

if nargin < 7
  plevRange = [1100, 0]; % hPa, full column
end

if nargin < 6
  latRange = [-90, 90];
end

if plevRange(2)>plevRange(1)
	tmp=plevRange(1);
	plevRange(1)=plevRange(2);
	plevRange(2)=tmp;
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
  thisFile = dataFile{fileI};
  fileInfo = ncinfo(thisFile);
  varinfo = fileInfo.Variables;

  plevVarName = [];
  for ii = 1:length(varinfo)
    varNameList{ii} = [varinfo(ii).Name];
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
    lon = ncread(thisFile, 'lon');
    lat = ncread(thisFile, 'lat');

    plev = readPressureLevels(thisFile, plevVarName);
    latIdx = find(lat <= latRange(2) & lat >= latRange(1));
    nLat = length(latIdx);
    lat = lat(latIdx);
    pIdx = find(plev >= plevRange(2) & plev <= plevRange(1));
    nP = length(pIdx);
    if (~strcmp(varName, 'ot') & ~strcmp(varName, 'os'))
    	plev = plev(pIdx)/100; % convert to hPa
    else
        plev = plev(pIdx)/1e4; % convert to dbar
    end

    monthlyData = nan(nLat, nP, nMonths);
  end

  v = single(ncread(thisFile, varName));
  if hasAttribute(thisFile, varName, 'missing_value')
    missingValue = ncreadatt(thisFile, varName, 'missing_value');
    v(abs(v - missingValue) < 1) = NaN;
  end
  if hasAttribute(thisFile, varName, '_FillValue')
    missingValue = ncreadatt(thisFile, varName, '_FillValue');
    v(abs(v - missingValue) < 1) = NaN;
  end

  v_units = ncreadatt(thisFile, varName, 'units');

  v_units = adjustUnits(v_units, varName);
  [startTime_thisFile, stopTime_thisFile] = parseDateInFileName(dataFile{fileI});

  monthIdx1 = numberOfMonths(startTime, startTime_thisFile);
  monthIdx2 = numberOfMonths(startTime, stopTime_thisFile);

  nMonths_thisFile = size(v,4);

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
  monthlyData(:,:,monthIdx1:monthIdx2) = meanExcludeNaN(v(:, latIdx, pIdx, idx2Data_start:idx2Data_stop),1);
  long_name = ncreadatt(thisFile, varName, 'long_name');
  clear v;
end

% We now determine the relevant months within a year using monthIdx and start month
monthIdxAdj = mod(monthIdx - startTime.month, 12) + 1;

var_clim = squeeze(simpleClimatology(monthlyData,3, monthIdxAdj));

figure;
%contourf(lat, -plev, var_clim, 'linewidth', 2);
contourf(lat, -plev, var_clim', 30, 'linecolor', 'none');
if ~isempty(find(isnan(var_clim(:))))
  cmap = colormap();
  cmap(1,:) = [1,1,1];
  colormap(cmap);
end
grid on;
set(gca, 'fontweight', 'bold');
currYTick = get(gca, 'ytick')';
currYTick(currYTick ~= 0) = - currYTick(currYTick ~= 0);
set(gca, 'yticklabel', num2str(currYTick));
xlabel('Latitude (deg)');
if (~strcmp(varName, 'ot') & ~strcmp(varName, 'os'))
	ylabel('Pressure level (hPa)');
else
	ylabel('Pressure level (dbar)');
end
cb = colorbar('southoutside');
set(get(cb,'xlabel'), 'string', [long_name '(' v_units ')'], 'FontSize', 16);
title([varName ', ' date2Str(startTime, '/') '-' date2Str(stopTime, '/') ' zonal mean map climatology (' v_units '), ' seasonStr(monthIdx)], 'fontsize', 13, 'fontweight', 'bold');
print(gcf, figFile, '-djpeg');

data.dimNames = {'plev', 'latitude'};
data.nDim = 2;
data.dimSize = [length(lat), length(plev)];
data.dimVars = {lat, plev};
data.var = var_clim;
data.varName = varName;
if (~strcmp(varName, 'ot') & ~strcmp(varName, 'os'))
	data.dimVarUnits = {'degree_north', 'hPa'};
else
	data.dimVarUnits = {'degree_north', 'decibar'};
end
data.varUnits = v_units;
data.varLongName = long_name;

status = 0;

if ~isempty(outputFile);
  status = storeDataInNetCDF(data, outputFile);
end
