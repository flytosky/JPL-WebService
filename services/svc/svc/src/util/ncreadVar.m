function v = ncreadVar(file, var)
%
% This function reads variable with name specified by var and store in v
% It makes missing value and _fillValue "NaN"
%
v = single(ncread(file, var));

if hasAttribute(file, var, 'missing_value')
  missingValue = ncreadatt(file, var, 'missing_value');
  if hasAttribute(file, var, 'scale_factor')
    scale_factor = ncreadatt(file, var, 'scale_factor');
    missingValue = scale_factor * missingValue;
  end

  if hasAttribute(file, var, 'add_offset')
    add_offset = ncreadatt(file, var, 'add_offset');
    missingValue = missingValue + add_offset;
  end

  v(abs(v - missingValue) < 1) = NaN;
end

if hasAttribute(file, var, '_fillvalue')
  fillValue = ncreadatt(file, var, '_fillvalue');

  if hasAttribute(file, var, 'scale_factor')
    scale_factor = ncreadatt(file, var, 'scale_factor');
    fillValue = scale_factor * fillValue;
  end

  if hasAttribute(file, var, 'add_offset')
    add_offset = ncreadatt(file, var, 'add_offset');
    fillValue = fillValue + add_offset;
  end

  v(abs(v - fillValue) < 1) = NaN;
end

if hasAttribute(file, var, '_FillValue')
  fillValue = ncreadatt(file, var, '_FillValue');

  if hasAttribute(file, var, 'scale_factor')
    scale_factor = ncreadatt(file, var, 'scale_factor');
    fillValue = scale_factor * fillValue;
  end

  if hasAttribute(file, var, 'add_offset')
    add_offset = ncreadatt(file, var, 'add_offset');
    fillValue = fillValue + add_offset;
  end

  v(abs(v - fillValue) < 1) = NaN;
end

