function status = displayConditionalSampling(dataFile, figFile, varName, startTime, stopTime, lonRange, latRange, monthIdx, plevRange, largeScaleDataFile, largeScaleVarName, largeScaleValueBinB, largeScalePlev, outputFile)
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
%   outputData	-- an optional argument to determine whether to generate a data file
%
% Output:
%   status	-- a status flag, 0 = okay, -1 something is not right
%
% Author: Chengxing Zhai
%
% Revision history:
%   2013/09/30:	Initial version, cz
%
status = -1;

% Need to read out first the data to be sorted
nMonths = numberOfMonths(startTime, stopTime);

printf('number of month = %d\n', nMonths);

monthlyData = [];

% This loads the large scale variabe data
largeScaleVarData = readTwoDimData(largeScaleDataFile, largeScaleVarName, startTime, stopTime, lonRange, latRange, largeScalePlev);

[idxArrayForEachBin, binCenterValues, nSamples] = generateIdxForBins(largeScaleValueBinB, largeScaleVarData.data);
nBins = length(binCenterValues);

% Let us first assume the same grid
% We now sort the large scale variable aaccording to the bin
% sorted data mean and stddev for each bin
v_sorted_m = [];
v2_sorted_m = [];
n_sorted = zeros(nBins,1);
v_sorted_std = [];

dataIsTwoDim = false;

nFiles = length(dataFile);
printf('number of files = %d\n', nFiles);
v = [];
lon = [];
lat = [];

file_start_time = {};
file_stop_time = {};

for fileI = 1:nFiles
  fd = netcdf(dataFile{fileI}, 'r');

  if isempty(v_sorted_m)
    lon = fd{'lon'}(:);
    lat = fd{'lat'}(:);

    [lon, lat, lonIdx, latIdx] = subIdxLonAndLat(lon, lat, lonRange, latRange);
    nLon = length(lon);
    nLat = length(lat);

    if isempty(plevRange)
      dataIsTwoDim = true;
    elseif max(plevRange) <= 0
      dataIsTwoDim = true;
    else
      dataIsTwoDim = false;
      plev = readPressureLevels(fd, 'plev');
      if length(plevRange) == 1
        [mV, mIdx] = min(abs(plevRange - plev));
      else
        mIdx = find(plev >= min(plevRange) & plev <= max(plevRange));
      end
      plev = plev(mIdx);
      nP = length(plev);
    end

    long_name = fd{varName}.long_name;

    if dataIsTwoDim
      v_sorted_m = zeros(nBins, 1);
      v2_sorted_m = zeros(nBins, 1);
      v_sorted_std = zeros(nBins, 1);
    else
      v_sorted_m = zeros(nBins, nP, 'single');
      v2_sorted_m = zeros(nBins, nP, 'single');
      v_sorted_std = zeros(nBins, nP, 'single');
    end
  end

  v = single(fd{varName}(:));
  if(~isempty(fd{varName}.missing_value))
    v(abs(v - fd{varName}.missing_value) < 1) = NaN;
  end

  v_units = fd{varName}.units;

  [startTime_thisFile, stopTime_thisFile] = parseDateInFileName(dataFile{fileI});

  file_start_time{fileI} = startTime_thisFile;
  file_stop_time{fileI} = stopTime_thisFile;

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

  for pI = 1:nP
    if dataIsTwoDim
      thisTwoDimSlice = v(idx2Data_start:idx2Data_stop,latIdx,lonIdx);
    else
      thisTwoDimSlice = v(idx2Data_start:idx2Data_stop, mIdx(pI), latIdx,lonIdx);
    end
    for binI = 1:nBins
      idx_in_thisFile = (find(idxArrayForEachBin{binI} > (monthIdx1-1)*nLat*nLon & idxArrayForEachBin{binI} <= monthIdx2*nLat*nLon));
      if pI == 1
        n_sorted(binI,1) = n_sorted(binI,1) + length(idx_in_thisFile);
      end
      v_sorted_m(binI,pI) = v_sorted_m(binI,pI) + sum(thisTwoDimSlice(idxArrayForEachBin{binI}(idx_in_thisFile)));
      v2_sorted_m(binI,pI) = v2_sorted_m(binI,pI) + sum(thisTwoDimSlice(idxArrayForEachBin{binI}(idx_in_thisFile)).^2);
    end
  end
  ncclose(fd);
end

for binI = 1:nBins
  if n_sorted(binI) ~= nSamples(binI)
    warning('Inconsistent indexing, number of data points do not match!');
    keyboard;
  else
    v_sorted_m(binI,:) = v_sorted_m(binI,:) / n_sorted(binI);
    v2_sorted_m(binI,:) = v2_sorted_m(binI,:) / n_sorted(binI);
    v_sorted_std(binI,:) = sqrt((v2_sorted_m(binI,:) - v_sorted_m(binI,:).^2) / (n_sorted(binI) - 1));
  end
end

% We now determine the relevant months within a year using monthIdx and start month
monthIdxAdj = mod(monthIdx - startTime.month, 12) + 1;

% We now determine the relevant time range used for this climatology calculation
[real_startTime, real_stopTime] = findRealTimeRange(file_start_time, file_stop_time, startTime, stopTime);

figure;
if dataIsTwoDim
  [ax, h1, h2] = plotyy(binCenterValues, v_sorted_m, binCenterValues, n_sorted);
  set(h1, 'linesytle', 'ks-', 'linewidth', 2, 'markersize', 6);
  set(h2, 'linesytle', 'g--', 'linewidth', 3);
  xlabel([largeScaleVarName '(' largeScaleVarData ')' ]);
  ylabel(ax(1),[varName '(' v_units ')']);
  ylabel(ax(2),'Number of samples');
  set(ax(1), 'fontweight', 'bold');
  set(ax(2), 'fontweight', 'bold');
  grid on;
  title([varName ', ' date2Str(startTime, '/') '-' date2Str(stopTime, '/') ', sorted by ' largeScaleVarName ], 'fontsize', 13, 'fontweight', 'bold');
else
  contourf(binCenterValues, -plev, v_sorted_m', 30, 'linecolor', 'none');
  if ~isempty(find(isnan(v_sorted_m(:))))
    cmap = colormap();
    cmap(1,:) = [1,1,1];
    colormap(cmap);
  end
  grid on;
  set(gca, 'fontweight', 'bold');
  currYTick = get(gca, 'ytick')';
  currYTick(currYTick ~= 0) = - currYTick(currYTick ~= 0);
  set(gca, 'yticklabel', num2str(currYTick));
  xlabel(largeScaleVarData.v_units);
  if (~strcmp(varName, 'ot') & ~strcmp(varName, 'os'))
        ylabel('Pressure level (hPa)');
  else
        ylabel('Pressure level (dbar)');
  end
  cb = colorbar('southoutside');
  set(get(cb,'xlabel'), 'string', [long_name '(' v_units ')'], 'FontSize', 16);
  title([varName ', ' date2Str(startTime, '/') '-' date2Str(stopTime, '/') ' sorted by ' largeScaleVarName ], 'fontsize', 13, 'fontweight', 'bold');
end
print(gcf, figFile, '-djpeg');
% adding title for color bar

data.dimNames = {'plev', [largeScaleVarName 'Bin']};
data.nDim = 2;
data.dimSize = [length(plev), nBins];
data.dimVars = {plev, binCenterValues};
data.var = v_sorted_m;
data.varName = varName;
data.dimVarUnits = {'Pa', largeScaleVarData.v_units};
data.varUnits = v_units;
data.varLongName = long_name;

status = 0;

if ~isempty(outputFile);
  status = storeDataInNetCDF(data, outputFile);
end
