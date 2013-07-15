function status = storeDataInNetCDF(data, fileName)
%
% This file stores data in netCDF format
%
status = -1;

nc = netcdf(fileName, 'c');

nDim = data.nDim;

for ii = 1:nDim
  nc(data.dimNames{ii}) = data.dimSize(ii);
end

for ii = 1:nDim
  nc{data.dimNames{ii}} = ncdouble(data.dimNames{ii});
end

for ii = 1:nDim
  nc{data.dimNames{ii}}(:) = data.dimVars{ii};
end

for ii = 1:nDim
  nc{data.dimNames{ii}}.units = data.dimVarUnits{ii};
end

nc{data.varName} = ncdouble(data.dimNames{:});
nc{data.varName}(:) = data.var;
nc{data.varName}.units = data.varUnits;
nc{data.varName}.name = data.varLongName;

close(nc);

status = 0;
