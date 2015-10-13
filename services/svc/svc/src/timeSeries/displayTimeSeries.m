function status = displayTimeSeries(dataInfo, startTime, stopTime, figFile, outputFile, displayOpt)
%
% This function extracts relevant data from the data file list according
% the specified temporal range [startTime, stopTime]
%
% Input:
%   dataInfo	-- a structure array contains information of variables
%		-- dataFile	-- a list of relevant data files
%		-- varName	-- the physical variable of interest, or to be displayed
%		-- sourceName	-- information regarding the data source, for dipslay
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

lg_str = cell(nVars,1);
v_units = cell(nVars,1);
for varI = 1:nVars
varName = dataInfo(varI).varName;
lg_str{varI} = strrep(dataInfo(varI).sourceName, '_', '\_');

monthlyData = [];
nFiles = length(dataInfo(varI).dataFile);
v = [];
lon = [];
lat = [];

for fileI = 1:nFiles
  thisFile = dataInfo(varI).dataFile{fileI};

  if isempty(monthlyData)
    lon = ncread(thisFile, 'lon');
    lat = ncread(thisFile, 'lat');

    [lon, lat, lonIdx, latIdx] = subIdxLonAndLat(lon, lat, dataInfo(varI).lonRange, dataInfo(varI).latRange);

    nLat = length(latIdx);
    monthlyData = nan(nMonths,1);
  end

  v = ncreadVar(thisFile, varName);
  v_units{varI} = ncreadatt(thisFile, varName, 'units');

  [startTime_thisFile, stopTime_thisFile] = parseDateInFileName(thisFile);

  monthIdx1 = numberOfMonths(startTime, startTime_thisFile);
  monthIdx2 = numberOfMonths(startTime, stopTime_thisFile);

  % Determine whether this variable is 2-d or 3-d
  f_info = ncinfo(thisFile);
  varList = {f_info.Variables.Name};
  idx = find(strcmp(varList, 'plev'));

  varIs2d = isempty(idx);
  if varIs2d
    nMonths_thisFile = size(v,3);
  else
    nMonths_thisFile = size(v,4);
  end

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

  if varIs2d
    monthlyData(monthIdx1:monthIdx2) = averageOverSphere(v(lonIdx, latIdx, idx2Data_start:idx2Data_stop), lat, dataInfo(varI).latRange);
  else
    plev = ncread(thisFile, 'plev');
    [p_idx, p_alphas] = linearInterpHelper(dataInfo(varI).plev, plev, 'log');
    monthlyData(monthIdx1:monthIdx2) = p_alphas(1) * averageOverSphere(squeeze(v(lonIdx, latIdx, p_idx(1), idx2Data_start:idx2Data_stop)), lat, dataInfo(varI).latRange);
    for pIdx = 2:length(p_idx)
      monthlyData(monthIdx1:monthIdx2) = monthlyData(monthIdx1:monthIdx2) + p_alphas(pIdx) * averageOverSphere(squeeze(v(lonIdx, latIdx, p_idx(pIdx), idx2Data_start:idx2Data_stop)), lat, dataInfo(varI).latRange);
    end
  end
  long_name{varI} = ncreadatt(thisFile, varName, 'long_name');
  clear v;
end

dataForDisplay(:,varI) = monthlyData;
lg_str{varI} = [lg_str{varI} ':' long_name{varI}];

end

nYears = stopTime.year - startTime.year + 1;
deltaYear = 1+floor(nYears/12);
nXTick = ceil(nYears/deltaYear);
yearVec = startTime.year+deltaYear*(0:nXTick);
yearStr = cell(nXTick+1, 1);
for ii = 1:(nXTick+1)
  yearStr{ii} = num2str(yearVec(ii));
end

[x_opt, y_opt, z_opt] = decodeDisplayOpt(displayOpt);

colorOrder = {'b', 'g', 'r', 'm', 'c', 'k'};
markerOrder = {'s', 'o', 'd', 'v', '^', 'p', '>', '<', 'x', '*', 'h'};

figure(1);
clf;
for varI = 1:nVars
lin_style = [colorOrder{1 + mod(varI-1,6)} markerOrder{1 + mod(varI-1, 11)} '-'];
plot(1:nMonths, dataForDisplay(:,varI), lin_style, 'linewidth', 2);
hold on;
end
xlabel('Year')
set(gca, 'fontweight', 'bold');
set(gca, 'xtick', (2-startTime.month)+(12*deltaYear)*(0:nXTick));
set(gca, 'xticklabel', yearStr); 
grid on;
ylabel(['Mean (' v_units{1} ')']);
legend(lg_str, 'location', 'best');
if nVars > 1
title([long_name{1} ', average value over lon(' num2str(dataInfo(1).lonRange(1)) ',' num2str(dataInfo(1).lonRange(2)) ')deg, lat(' num2str(dataInfo(1).latRange(1)) ',' num2str(dataInfo(1).latRange(2)) ')deg, (' v_units{1} ') and more']);
else
title([long_name{1} ', average value over lon(' num2str(dataInfo(1).lonRange(1)) ',' num2str(dataInfo(1).lonRange(2)) ')deg, lat(' num2str(dataInfo(1).latRange(1)) ',' num2str(dataInfo(1).latRange(2)) ')deg, (' v_units{1} ')']);
end
if x_opt
  set(gca, 'xscale', 'log');
end
if y_opt | z_opt
  set(gca, 'yscale', 'log');
end
print(gcf, figFile, '-djpeg');

data.dimNames = {'monthIdx', 'varIdx'};
data.nDim = 2;
data.dimSize = [nMonths, nVars];
data.dimVars = {1:nMonths, 1:nVars};
data.var = dataForDisplay;
data.varName = dataInfo(1).varName;
data.dimVarUnits = {'month', 'N/A'};
data.varUnits = v_units{1};
data.varLongName = long_name{1};

status = 0;

if ~isempty(outputFile)
  status = storeDataInNetCDF(data, outputFile);
end
