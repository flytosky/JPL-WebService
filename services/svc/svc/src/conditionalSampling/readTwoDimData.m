function twoDimData = readTwoDimData(dataFiles, varName, startTime, stopTime, lonRange, latRange, pRange)
%
% This function reads two dimensional data from netcdf files and concatenate along the
% time dimension (3rd dimension)
%
status = -1;

% Need to read out first the data to be sorted

nMonths = numberOfMonths(startTime, stopTime);

printf('number of month = %d\n', nMonths);

if isempty(pRange)
  noVertDim = true;
else
  noVerDim = (max(pRange) <= 0);
end

twoDimData.data = [];

nFiles = length(dataFiles);

for fileI = 1:nFiles
  dataFile = dataFiles{fileI};
  fd = netcdf(dataFile, 'r');
  if isempty(twoDimData.data)
    lon = fd{'lon'}(:);
    lat = fd{'lat'}(:);
    [lon, lat, lonIdx, latIdx] = subIdxLonAndLat(lon, lat, lonRange, latRange);
    nLon = length(lon);
    nLat = length(lat);

    twoDimData.name = fd{varName}.long_name;
    twoDimData.units = fd{varName}.units;
    twoDimData.data = nan(nMonths, nLat, nLon, 'single');

    % Check 3-d
    if ~noVertDim
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
        noVertDim = true;
        warning('No variable for pressure level found, assuming two dimensional field');
      else
        plev = readPressureLevels(fd, plevVarName);
        if length(pRange) == 1
          [mV, pIdx] = min(abs(plev - pRange));
        else
          pIdx = find(plev >= min(pRange) & plev <= max(pRange));
        end
      end
    end
  end
  v = fd{varName}(:);
  if(~isempty(fd{varName}.missing_value))
    v(abs(v - fd{varName}.missing_value) < 1) = NaN;
  end

  twoDimData.v_units = fd{varName}.units;
  [startTime_thisFile, stopTime_thisFile] = parseDateInFileName(dataFile);

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

  if noVertDim
    twoDimData.data(monthIdx1:monthIdx2, :, :) = v(idx2Data_start:idx2Data_stop,latIdx,lonIdx);
  else
    twoDimData.data(monthIdx1:monthIdx2, :, :) = squeeze(meanExcludeNaN(v(idx2Data_start:idx2Data_stop, pIdx, latIdx,lonIdx), 2));
  end
  ncclose(fd);
end

twoDimData.lon = lon;
twoDimData.lat = lat;
twoDimData.startTime = startTime;
twoDimData.stopTime = stopTime;
if ~noVertDim
  twoDimData.plev = plev(pIdx);
end

