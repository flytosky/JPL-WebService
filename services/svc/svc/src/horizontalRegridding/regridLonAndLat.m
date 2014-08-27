function status = regridLonAndLat(inputFile, outputFile, varName, lon, lat)
%
% This function regrids data in input file according to the specified longitude
% an latitude and output the data to output file
%
status = -1;

% Let us get the information from the input file
inFileInfo = ncinfo(inputFile);

outFileInfo.Name = inFileInfo.Name;
outFileInfo.Format = inFileInfo.Format;
outFileInfo.Groups = inFileInfo.Groups;
outFileInfo.Attributes = inFileInfo.Attributes;

dimNames = {'time', 'bnds'};
nDims = length(dimNames);

for ii = 1:nDims
  idx = lookupDim(dimNames{ii}, inFileInfo);
  if length(idx) == 1
    outFileInfo.Dimensions(ii) = inFileInfo.Dimensions(idx(1));
  else
    warning(['!!! missing dimension info: ' dimNames{ii} ]);
    keyboard;
  end
end

nLon = length(lon);
nLat = length(lat);

outFileInfo.Dimensions(nDims+1) = struct('Name', 'lon', 'Length', nLon, 'Unlimited', false);
outFileInfo.Dimensions(nDims+2) = struct('Name', 'lat', 'Length', nLat, 'Unlimited', false);

% Determine vertical scales
idx = lookupDim('plev', inFileInfo)
if ~isempty(idx)
  outFileInfo.Dimensions(nDims+3) = inFileInfo.Dimensions(idx(1));
  verDimExist = true;
else
  verDimExist = false;
end

varList = {'time', 'time_bnds', varName};
nVar = length(varList);

for ii = 1:nVar
  idx = lookupVar(varList{ii}, inFileInfo);
  if length(idx) == 1
    outFileInfo.Variables(ii) = rmfield(inFileInfo.Variables(idx(1)), 'Checksum'); % "checksum is not implemented for netcdf-3
  else
    warning(['!!! missing variable: ' varList{ii} ]);
    keyboard;
  end
  if strcmp(varList{ii}, varName)
    if verDimExist
      outFileInfo.Variables(ii).Dimensions(1:4) = outFileInfo.Dimensions([nDims+1,nDims+2, nDims+3,1]);
    else
      outFileInfo.Variables(ii).Dimensions(1:3) = outFileInfo.Dimensions([nDims+1,nDims+2,1]);
    end
  end
end

ncwriteschema(outputFile, outFileInfo);
ncwrite(outputFile, 'time', ncread(inputFile, 'time'));
ncwrite(outputFile, 'time_bnds', ncread(inputFile, 'time_bnds'));
obs4MIPs_write_lon_and_bnds(outputFile, lon);
obs4MIPs_write_lat_and_bnds(outputFile, lat);
if  verDimExist
  obs4MIPs_write_plev(outputFile, ncread(inputFile, 'plev'));
end

data = ncread(inputFile, varName);

dataSize = size(data);

if length(dataSize) < 4
  noVertDim = true;
  nMonths = size(data,3);
else
  noVertDim = false;
  nMonths = size(data,4);
end

nLon = length(lon);
nLat = length(lat);

data = data(:,:,:); % make the rest of dimensions in linear index
nMaps = size(data,3); % this could be a combination of vertical and time dimensions

lon_data = ncread(inputFile, 'lon');
lat_data = ncread(inputFile, 'lat');

if isvector(lon_data) && isvector(lat_data)
  % Let us determine whether 
  [lonGrid_status, lonIdx] = isSubgrid(lon, lon_data);
  [latGrid_status, latIdx] = isSubgrid(lat, lat_data);
  if lonGrid_status && latGrid_status
    opt = 'subidxing';
  else
    opt = '2d_interp_reg';
    nLon_data = length(lon_data);
    nLat_data = length(lat_data);
  end
else
  opt = '2d_interp_irreg';
  [nLon_data, nLat_data] = size(lon_data);
  lonlon = repmat(lon(:), 1, nLat);
  latlat = repmat(lat(:)', nLon, 1);
end

data_regridded = nan(nLon, nLat, nMaps, 'single');

if hasAttribute(inputFile, varName, 'missing_value')
  missingValue = ncreadatt(inputFile, varName, 'missing_value');
  data(abs(data - missingValue) < 1) = NaN;
end
if hasAttribute(inputFile, varName, '_FillValue')
  missingValue = ncreadatt(inputFile, varName, '_FillValue');
  data(abs(data - missingValue) < 1) = NaN;
end

tic;
switch opt
  case '2d_interp_reg',
    disp('regridding a regular 2-d grid');
    for ii = 1:nMaps
      data_regridded(:, :, ii) = twoDimInterpOnSphere(lon_data, lat_data, data(:, :,ii), lon, lat, 'linear');
    end
  case '2d_interp_irreg',
    disp('regridding an irregular 2-d grid');
    % make sure the longitude is in the correct range
    maxLon = max(lon_data(:));
    minLon = min(lon_data(:));
    lonlon = mod(lonlon - minLon, 360) + minLon;
    for ii = 1:nMaps
      data_regridded(:, :, ii) = griddata(lon_data, lat_data, data(:,:,ii), lonlon, latlat, 'linear');
    end
  case 'subidx',
    disp('subindexing a regular 2-d grid');
    data_regridded = data(lonIdx, latIdx, :);
  otherwise, % treating as sub indexing
    disp(['Other option: ' opt ', using sub indexing']);
    data_regridded = data(lonIdx, latIdx, :);
end
toc;
clear data; % save memory

if verDimExist
  data_regridded = reshape(data_regridded, nLon, nLat, [], outFileInfo.Dimensions(1).Length);
end

ncwrite(outputFile, varName, data_regridded);

status = 0;
