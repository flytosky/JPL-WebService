function status = displayVerticalProfile(dataFile, figFile, varName, startTime, stopTime, lonRange, latRange, monthIdx)
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
  latRange = [0, 360];
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
      p0 = 1.013e5; % 1atm = 1.013e5 Pa
      plev = fd{'lev'}(:)*p0;
    end

    latIdx = find(lat <= latRange(2) & lat >= latRange(1));
    nLat = length(latIdx);
    lat = lat(latIdx);
    nP = length(plev);

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

    monthlyData = nan(nMonths, nP);
  end

  v = fd{varName}(:);
  if ~isempty(fd{varName}.missing_value)
    v(abs(v - fd{varName}.missing_value) < 1) = NaN; 
  end
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
  monthlyData(monthIdx1:monthIdx2, :) = meanExcludeNaN(meanExcludeNaN(v(idx2Data_start:idx2Data_stop,:,latIdx,lonIdx),3),4);
  ncclose(fd);
end

% We now determine the relevant months within a year using monthIdx and start month
monthIdxAdj = mod(monthIdx - startTime.month, 12) + 1;

var_clim = squeeze(simpleClimatology(monthlyData,1, monthIdxAdj));
figure;
semilogx(var_clim, -plev/100, 'ks-', 'linewidth', 2);
grid on;
set(gca, 'fontweight', 'bold');
currYTick = get(gca, 'ytick')';
currYTick(currYTick ~= 0) = - currYTick(currYTick ~= 0);
set(gca, 'yticklabel', num2str(currYTick));
xlabel(['Average (' v_units ')']);
ylabel('Pressure level (hPa)');
xlim(max(var_clim)*[1e-4, 1.1]);
title([varName ', ' date2Str(startTime) '-' date2Str(stopTime) ' vertical profile climatology (' v_units '), ' seasonStr(monthIdx)], 'fontsize', 13, 'fontweight', 'bold');
print(gcf, figFile, '-djpeg');
