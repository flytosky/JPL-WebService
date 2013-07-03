function status = displayThreeDimZonalMean(dataFile, figFile, varName, startTime, stopTime, latRange, plevRange, monthIdx)
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
%
% Output:
%   status	-- a status flag, 0 = okay, -1 something is not right
%
% Author: Chengxing Zhai
%
% Revision history:
%   2012/03/25:	Initial version, cz
%

if nargin < 8
  monthIdx = 1:12;
end

if nargin < 7
  plevRange = [1100, 0]; % hPa, full column
end

if nargin < 6
  latRange = [-90, 90];
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

    if strcmp(plevVarName, 'plev')
      plev = fd{'plev'}(:);
    else
      switch lower(fd{'lev'}.units)
        case 'm',
          plev = altitude2Pressure(fd{'lev'}(:)/1000)*100; % m -> Km -> hPa -> Pa
      
        otherwise,
          p0 = 1.013e5; % 1atm = 1.013e5 Pa
          plev = fd{'lev'}(:)*p0;
      end
    end

    latIdx = find(lat <= latRange(2) & lat >= latRange(1));
    nLat = length(latIdx);
    lat = lat(latIdx);
    pIdx = find(plev > plevRange(2) & plev <= plevRange(1));
    nP = length(pIdx);
    plev = plev(pIdx)/100;

    monthlyData = nan(nMonths, nP, nLat);
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
  monthlyData(monthIdx1:monthIdx2, :, :) = meanExcludeNaN(v(idx2Data_start:idx2Data_stop,pIdx,latIdx,:),4);
  ncclose(fd);
end

% We now determine the relevant months within a year using monthIdx and start month
monthIdxAdj = mod(monthIdx - startTime.month, 12) + 1;

var_clim = squeeze(simpleClimatology(monthlyData,1, monthIdxAdj));

figure;
contourf(lat, -plev, var_clim, 'linewidth', 2);
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
ylabel('Pressure level (hPa)');
colorbar('southoutside');
title([varName ', ' date2Str(startTime) '-' date2Str(stopTime) ' zonal mean map climatology (' v_units '), ' seasonStr(monthIdx)], 'fontsize', 13, 'fontweight', 'bold');
print(gcf, figFile, '-djpeg');
