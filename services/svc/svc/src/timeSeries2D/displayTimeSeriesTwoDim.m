function status = displayTimeSeriesTwoDim(dataFile, figFile, varName, startTime, stopTime, lonRange, latRange)
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
if nargin < 7
  latRange = [-90, 90];
end

if nargin < 6
  lonRange = [0, 360];
end 

status = -1;

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

    [lon, lat, lonIdx, latIdx] = subIdxLonAndLat(lon, lat, lonRange, latRange);

    nLat = length(latIdx);
    monthlyData = nan(nMonths,1);
  end

  v = fd{varName}(:);

  v(abs(v - fd{varName}.missing_value) < 1) = NaN;

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
  %monthlyData(monthIdx1:monthIdx2) = meanExcludeNaN(meanExcludeNaN(v(idx2Data_start:idx2Data_stop,latIdx,lonIdx),2),3);
  monthlyData(monthIdx1:monthIdx2) = averageOverSphere(v(idx2Data_start:idx2Data_stop,latIdx,lonIdx), lat);
end

yearVec = startTime.year:stopTime.year;
nYears = length(yearVec);
yearStr = cell(nYears, 1);
for ii = 1:nYears
  yearStr{ii} = num2str(yearVec(ii));
end

deltaYear = 1+floor(nYears/12);

figure(1);
clf;
plot(1:nMonths, monthlyData, 's-', 'linewidth', 2);
xlabel('Year')
set(gca, 'fontweight', 'bold');
set(gca, 'xtick', [(2-startTime.month):12*deltaYear:nMonths]);
set(gca, 'xticklabel', {yearStr{1:deltaYear:end}}); 
grid on;
ylabel(['Mean (' v_units ')']);
title([varName ', average value over lon(' num2str(lonRange(1)) ',' num2str(lonRange(2)) ')deg, lat(' num2str(latRange(1)) ',' num2str(latRange(2)) ')deg, (' v_units ')']);
print(gcf, figFile, '-djpeg');
