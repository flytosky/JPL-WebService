function status = displayTimeSeries(dataInfo, startTime, stopTime, figFile, outputFile, displayOpt)
%function status = displayTimeSeries(dataInfo, dataFile, figFile, varNames, startTime, stopTime, lonRange, latRange, plevRange, outputFile, displayOpt)
%
% This function extracts relevant data from the data file list according
% the specified temporal range [startTime, stopTime]
%
% Input:
%   dataInfo	-- a structure array contains information of variables
%		-- dataFile	-- a list of relevant data files
%		-- varName	-- the physical variable of interest, or to be displayed
%   		-- lonRnage	-- an optional argument to specify box boundary along longitude
%   		-- latRnage	-- an optional argument to specify box boundary along latitude
%   		-- plevRange	-- specifies pressure level(s), single value will be treated as a single level, two values are treated as a range
%   startTime	-- the start time of the temporal window over which the climatology is computed
%   stopTime	-- the stop time of the temporal window over which the climatology is computed
%   figFile	-- the name of the output file for storing the figure to be displayed
%   outputFile	-- the name of the output file for storing data of used by the figure
%   displayOpt	-- options to specify display
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
status = -1;

nVars = length(dataInfo);
nMonths = numberOfMonths(startTime, stopTime);
printf('number of month = %d\n', nMonths);

dataForDisplay = zeros(nMonths, nVars);

for varI = 1:nVars
varName = dataInfo(varI).varName;

monthlyData = [];
nFiles = length(datInfo(varI)dataFile);
v = [];
lon = [];
lat = [];

for fileI = 1:nFiles
  thisFile = dataFile{fileI};

  if isempty(monthlyData)
    lon = ncread(thisFile, 'lon');
    lat = ncread(thisFile, 'lat');

    [lon, lat, lonIdx, latIdx] = subIdxLonAndLat(lon, lat, lonRange, latRange);

    nLat = length(latIdx);
    monthlyData = nan(nMonths,1);
  end

  v = ncreadVar(thisFile, varName);
  v_units = ncreadatt(thisFile, varName, 'units');

  [startTime_thisFile, stopTime_thisFile] = parseDateInFileName(dataFile{fileI});

  monthIdx1 = numberOfMonths(startTime, startTime_thisFile);
  monthIdx2 = numberOfMonths(startTime, stopTime_thisFile);

  nMonths_thisFile = size(v,3);

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

  % Determine whether this variable is 2-d or 3-d
  f_info = ncinfo(thisFile);
  varList = {f_info.Variables.Name};
  idx = strfind(varList, 'plev');
  if isempty(idx)
    monthlyData(monthIdx1:monthIdx2) = averageOverSphere(v(lonIdx, latIdx, idx2Data_start:idx2Data_stop), lat);
  else
    plev = ncread(thisFile, 'plev');
    [p_idx, p_alphas] = linearInterpHelper(dataInfo{varI}.plev, plev, 'log');
    monthlyData(monthIdx1:monthIdx2) = p_alphas(1) * averageOverSphere(squeeze(v(lonIdx, latIdx, p_idx(1), idx2Data_start:idx2Data_stop)));
    for pIdx = 2:length(p_idx)
      monthlyData(monthIdx1:monthIdx2) = monthlyData(monthIdx1:monthIdx2) + p_alphas(pIdx) * averageOverSphere(squeeze(v(lonIdx, latIdx, p_idx(pIdx), idx2Data_start:idx2Data_stop)));
    end
  end
  long_name{varI} = ncreadatt(thisFile, varName, 'long_name');
  clear v;
end

dataForDisplay(:,varI) = monthlyData;

end

yearVec = startTime.year:stopTime.year;
nYears = length(yearVec);
yearStr = cell(nYears, 1);
for ii = 1:nYears
  yearStr{ii} = num2str(yearVec(ii));
end

deltaYear = 1+floor(nYears/12);

[x_opt, y_opt, z_opt] = decodeDisplayOpt(displayOpt);

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
if x_opt
  set(gca, 'xscale', 'log');
end
if y_opt | z_opt
  set(gca, 'yscale', 'log');
end
print(gcf, figFile, '-djpeg');

data.dimNames = {'monthIdx'};
data.nDim = 1;
data.dimSize = [nMonths];
data.dimVars = {1:nMonths};
data.var = monthlyData;
data.varName = varName;
data.dimVarUnits = {'month'};
data.varUnits = v_units;
data.varLongName = long_name;

status = 0;

if ~isempty(outputFile);
  status = storeDataInNetCDF(data, outputFile);
end
