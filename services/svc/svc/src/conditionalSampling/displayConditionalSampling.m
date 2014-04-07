function status = displayConditionalSampling(dataFile, figFile, varName, startTime, stopTime, lonRange, latRange, monthIdx, plevRange, largeScaleDataFile, largeScaleVarName, largeScaleValueBinB, largeScalePlev, outputFile, displayOpt)
%
% This function extracts relevant data from the data file list according
% the specified temporal range [startTime, stopTime]
%
% Input:
%   dataFile	-- a list of relevant data files
%   figFile	-- the name of the output file for storing the figure to be displayed
%   varName	-- the physical variable of interest, or to be displayed, CMIP5 variable name used in netcdf file
%   startTime	-- the start time of the temporal window over which the climatology is computed, string 'yyyymm'
%   stopTime	-- the stop time of the temporal window over which the climatology is computed, string 'yyyymm'
%   lonRnage	-- longitude boundary specification, expect [min, max] (deg)
%   latRnage	-- latitude boundary specification, expect [min, max] (deg)
%   monthIdx	-- specify months within a year, which is useful for computing climatology for a specific season.
%   plevRange	-- presssure level range in units of (Pa)
%   largeScaleDataFile	-- a list of relevant large scale data files
%   largeScaleVarName	-- CMIP5 name for the large scale variable
%   largeScaleValueBinB	-- bin boundary specification, either as a vector of bin boundaries or [min,max,nBin]
%   largeScalePlev	-- pressure level for the large scale variable, e.g. vertical velocity at 50000Pa
%   outputFile	-- a data file for storing plotting data in netcdf format
%   displayOpt	-- flags to specify display scale, linear vs logarithmic, 3-bits, in the order (z,y,x), 0=lin, 1=log, 
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

if nargin < 15
  displayOpt = 0;
end

% Need to read out first the data to be sorted
nMonths = numberOfMonths(startTime, stopTime);
monthList = monthListWithin(startTime, stopTime, monthIdx);

printf('number of month = %d\n', nMonths);

monthlyData = [];

% Let us first assume the same grid
% We now sort the large scale variable aaccording to the bin
% sorted data mean and stddev for each bin
v_sorted_m = [];
v2_sorted_m = [];
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
  thisFile = dataFile{fileI};

  if isempty(v_sorted_m)
    lon = ncread(thisFile, 'lon');
    lat = ncread(thisFile, 'lat');

    [lon, lat, lonIdx, latIdx] = subIdxLonAndLat(lon, lat, lonRange, latRange);
    nLon = length(lon);
    nLat = length(lat);

    % This loads the large scale variabe data
    largeScaleVarData = readAndRegridTwoDimData(largeScaleDataFile, largeScaleVarName, startTime, stopTime, lon, lat, largeScalePlev);
    nBinB = length(largeScaleValueBinB);
    if nBinB <= 0
      largeScaleValueBinB = generateBinB(largeScaleVarData.data(:), 20);
    elseif nBinB == 1
      largeScaleValueBinB = generateBinB(largeScaleVarData.data(:), nBinB-1);
    elseif nBinB == 2
      largeScaleValueBinB = linspace(largeScaleValueBinB(1), largeScaleValueBinB(2), 10 + 1);
    end

    nBinB = length(largeScaleValueBinB);
    nBins = nBinB - 1;
    n_sorted = zeros(nBins,1);

    [idxArrayForEachBin, binCenterValues, nSamples] = generateIdxForBins(largeScaleValueBinB, largeScaleVarData.data);

    if isempty(plevRange)
      dataIsTwoDim = true;
      nP = 1;
    elseif max(plevRange) <= 0
      dataIsTwoDim = true;
      nP = 1;
    else
      dataIsTwoDim = false;
      plev = readPressureLevels(thisFile, 'plev');
      if length(plevRange) == 1
        [mV, mIdx] = min(abs(plevRange - plev));
      else
        mIdx = find(plev >= min(plevRange) & plev <= max(plevRange));
      end
      plev = plev(mIdx);
      nP = length(plev);
    end

    long_name = ncreadatt(thisFile, varName, 'long_name');

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

  [startTime_thisFile, stopTime_thisFile] = parseDateInFileName(dataFile{fileI});

  file_start_time{fileI} = startTime_thisFile;
  file_stop_time{fileI} = stopTime_thisFile;

  monthIdx1 = numberOfMonths(startTime, startTime_thisFile);
  monthIdx2 = numberOfMonths(startTime, stopTime_thisFile);

  if dataIsTwoDim 
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
  monthListThisFile = find(monthList >= monthIdx1 & monthList <= monthIdx2);
  nMonthInThisFile = length(monthListThisFile);

  timeIdx = idx2Data_start:idx2Data_stop;
  for monthI = 1:nMonthInThisFile
    thisMonth = monthListThisFile(monthI);
    for pI = 1:nP
      if dataIsTwoDim
        thisTwoDimSlice = v(lonIdx, latIdx, timeIdx(monthI));
      else
        thisTwoDimSlice = v(lonIdx, latIdx, mIdx(pI), timeIdx(monthI));
      end
      for binI = 1:nBins
        idx_in_thisFile = mod(idxArrayForEachBin{binI}(find(idxArrayForEachBin{binI} > (thisMonth-1)*nLat*nLon & idxArrayForEachBin{binI} <= thisMonth*nLat*nLon))-1, nLat*nLon) + 1;
        if pI == 1
          n_sorted(binI,1) = n_sorted(binI,1) + length(idx_in_thisFile);
        end
        v_sorted_m(binI,pI) = v_sorted_m(binI,pI) + sum(thisTwoDimSlice(idx_in_thisFile));
        v2_sorted_m(binI,pI) = v2_sorted_m(binI,pI) + sum(thisTwoDimSlice(idx_in_thisFile).^2);
      end
    end
  end
  clear v;
end

for binI = 1:nBins
  %if n_sorted(binI) ~= nSamples(binI)
  %  warning('Inconsistent indexing, number of data points do not match!');
  %  keyboard;
  %else
    v_sorted_m(binI,:) = v_sorted_m(binI,:) / n_sorted(binI);
    v2_sorted_m(binI,:) = v2_sorted_m(binI,:) / n_sorted(binI);
    v_sorted_std(binI,:) = sqrt((v2_sorted_m(binI,:) - v_sorted_m(binI,:).^2) / (n_sorted(binI) - 1));
  %end

end

% We now determine the relevant time range used for this climatology calculation
[real_startTime, real_stopTime] = findRealTimeRange(file_start_time, file_stop_time, startTime, stopTime);

[x_opt, y_opt, z_opt] = decodeDisplayOpt(displayOpt);

figure;
if dataIsTwoDim
  if y_opt | z_opt
    if x_opt
      [ax, h1, h2] = plotyy(binCenterValues, v_sorted_m, binCenterValues, n_sorted, 'loglog', 'loglog');
    else
      [ax, h1, h2] = plotyy(binCenterValues, v_sorted_m, binCenterValues, n_sorted, 'semilogy', 'semilogy');
    end
  else
    if x_opt
      [ax, h1, h2] = plotyy(binCenterValues, v_sorted_m, binCenterValues, n_sorted, 'semilogx', 'semilogx');
    else
      [ax, h1, h2] = plotyy(binCenterValues, v_sorted_m, binCenterValues, n_sorted, 'plot', 'plot');
    end
  end
  set(h1, 'linestyle', '-', 'marker', 's', 'color', 'k', 'linewidth', 2, 'markersize', 6);
  set(h2, 'linestyle', '--', 'color', 'g', 'linewidth', 3);
  xlabel([largeScaleVarName '(' largeScaleVarData.units ')' ]);
  ylabel(ax(1),[varName '(' v_units ')']);
  ylabel(ax(2),'Number of samples');
  set(ax(1), 'fontweight', 'bold');
  set(ax(2), 'fontweight', 'bold');
  grid on;
  title([varName ', ' date2Str(startTime, '/') '-' date2Str(stopTime, '/') ', sorted by ' largeScaleVarName ], 'fontsize', 13, 'fontweight', 'bold');
else
  if z_opt
    z = log10(v_sorted_m' + 1e-4*(max(v_sorted_m(:)))); % to have dynamic range of 10^4
  else
    z = v_sorted_m';
  end

  if y_opt
    y = - log10(plev);
  else
    y = - plev;
  end

  [z_valid, y_valid, x_valid] = subsetValidData(z, y, binCenterValues);

  contourf(x_valid, y_valid, z_valid, 15, 'linecolor', 'none');

  if ~isempty(find(isnan(v_sorted_m(:))))
    cmap = colormap();
    cmap(1,:) = [1,1,1];
    colormap(cmap);
  end
  grid on;
  set(gca, 'fontweight', 'bold');
  currYTick = get(gca, 'ytick')';
  currYTick(currYTick ~= 0) = - currYTick(currYTick ~= 0);
  if y_opt
    set(gca, 'yticklabel', num2str(10.^(currYTick-2))); % Pa -> hPa
  else
    set(gca, 'yticklabel', num2str(currYTick/100)); % Pa -> hPa
  end
  xlabel(largeScaleVarData.v_units);
  if (~strcmp(varName, 'ot') & ~strcmp(varName, 'os'))
        ylabel('Pressure level (hPa)');
  else
        ylabel('Pressure level (dbar)');
  end
  
  cb = colorbar('southoutside');
  if z_opt
    set(cb, 'xticklabel', num2str(10.^(get(cb, 'xtick')'),3));
  end
  set(get(cb,'xlabel'), 'string', [long_name '(' v_units ')'], 'FontSize', 16);

  title([varName ', ' date2Str(startTime, '/') '-' date2Str(stopTime, '/') ' sorted by ' largeScaleVarName ], 'fontsize', 13, 'fontweight', 'bold');
end
print(gcf, figFile, '-djpeg');
% adding title for color bar

if dataIsTwoDim
  data.dimNames = {[largeScaleVarName 'Bin']};
  data.nDim = 1;
  data.dimSize = [nBins];
  data.dimVars = {binCenterValues};
  data.var = v_sorted_m;
  data.varName = varName;
  data.dimVarUnits = {largeScaleVarData.v_units};
  data.varUnits = v_units;
  data.varLongName = long_name;
else
  data.dimNames = {[largeScaleVarName 'Bin'], 'plev'};
  data.nDim = 2;
  data.dimSize = [nBins, length(plev)];
  data.dimVars = {binCenterValues, plev};
  data.var = v_sorted_m;
  data.varName = varName;
  data.dimVarUnits = {largeScaleVarData.v_units, 'Pa'};
  data.varUnits = v_units;
  data.varLongName = long_name;
end

status = 0;

if ~isempty(outputFile);
  status = storeDataInNetCDF(data, outputFile);
end
