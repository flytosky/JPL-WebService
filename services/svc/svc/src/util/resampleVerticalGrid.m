function status = resampleVerticalGrid(file_in, file_out, varName, plev)
%
% This file resamples the data in file_in vertically to the specified grid "plev"
% and then write the file to file_out. 
%

status = -1;
fd_in = netcdf(file_in, 'r');
fd_out = netcdf(file_out, 'c');

% get some info
varInfo = ncvar(fd_in);
nVar = length(varInfo);
levelVarName = [];
data = single(fd_in{varName}(:));

[nT, nP_orig,nLat,nLon] = size(data);

nP = length(plev);

data_regrided = zeros(nT,nP,nLat,nLon, 'single');

dimInfo = ncdim(fd_in);
nDim = length(dimInfo);
for dimI = 1:nDim
  thisDimName = ncname(dimInfo{dimI});
  if isempty(strfind(thisDimName, 'lev'))
    fd_out(thisDimName) = dimInfo{dimI}(:);
  else
    fd_out('plev') = nP;
  end
end

varList = {'lon', 'lat', 'time', 'lon_bnds', 'lat_bnds', 'time_bnds'};

% Copy all the dimension grid variables
for ii = 1:length(varList)
  copyVar(fd_out, fd_in, varList{ii});
end

% create vertical dimension grid
fd_out{'plev'} = ncdouble('plev');
fd_out{'plev'}(:) = plev;
fd_out{'plev'}.units = 'Pa';
fd_out{'plev'}.long_name = 'pressure';
fd_out{'plev'}.standard_name = 'air_pressure';
fd_out{'plev'}.axis = 'Z';
fd_out{'plev'}.positive = 'down';

% copy the global attributes
copyAtt(fd_out, fd_in);

fd_out{varName} = ncfloat('time', 'plev', 'lat', 'lon');

% We now go through the vertical coordinate
for varI = 1:nVar
  thisVarName = ncname(varInfo{varI});
  if ~isempty(strfind(thisVarName, 'plev'))
    plev_orig = fd_in{'plev'};
    % Compute a kernel matrix for computing linear interpolation
    % to save time. Interpolation is done using log scale
    K = computeInterpKernel(log(plev_orig(:)), log(plev(:)), 'linear');
    for tI = 1:nT
      data_regrided(tI,:) = reshape(K*squeeze(data(tI,:,:)), 1, []);
    end
    fd_out{varName}(:) = data_regrided;
    status = copyAtt(fd_out{varName}, fd_in{varName});
    close(fd_out);
    close(fd_in);
    return;
  elseif ~isempty(strfind(thisVarName, 'lev'))
    levelVarName = thisVarName;
    break;
  end
end

if isempty(levelVarName)
  error('No vertical coordinate found!'); 
end

% We  now get the information regarding the vertical coordinate,i.e. sigma or hybrid sigma coordinate
formula_str = fd_in{levelVarName}.formula;
standard_name = fd_in{levelVarName}.standard_name;
terms = fd_in{levelVarName}.formula_terms;
if isempty(formula_str)
  warning('No formula is found!');
end
formula = formulaParser(formula_str);
termPairs = reshape(strchop(terms, ' '),  2, []);

switch lower(standard_name)
  case {'atmosphere_ln_pressure_coordinate'},
    % Let us parse the formula
    formula_str_simple = strrep(formulat_str, 'exp', ' ');
    formula_str_simple = strrep(formulat_str_simple, '(', ' ');
    formula_str_simple = strrep(formulat_str_simple, ')', ' ');
    formula = formulaParser(formula_str_simple);
    
    p_ref_var = lookupTermName(formula.inputVars{1}, termPairs, 'p0');
    p0 = fd_in{p_ref_var}(:);
    lev_var = lookupTermName(formula.inputVars{2}, termPairs, 'lev');
    lev = fd_in{lev_var}(:);
    plev_orig = p0 * exp(-lev);
    K = computeInterpKernel(log(plev_orig(:)), log(plev(:)), 'linear');
    for tI = 1:nT
      data_regrided(tI,:) = reshape(K*squeeze(data(tI,:,:)), 1, []);
    end
    fd_out{varName}(:) = data_regrided;
    status = copyAtt(fd_out{varName}, fd_in{varName});
    close(fd_out);
    close(fd_in);
    return;
  case {'atmosphere_sigma_coordinate'},
    ptop_var = lookupTermName(formula.inputVars{1}, termPairs, 'ptop');
    ptop = fd_in{ptop_var}(:);
    b_var = lookupTermName(formula.inputVars{2}, termPairs, 'b');
    b = fd_in{b_var}(:);
    ps_var = lookupTermName(formula.inputVars{3}, termPairs, 'ps');
    ps = fd_in{ps_var}(:) - ptop;
    pverFunc = @(tI, latI, lonI) ptop*a + ps(tI, latI, lonI)*b;
  case {'atmosphere_hybrid_sigma_pressure_coordinate'},
    varIdx = 1;
    if length(formula.op) == 2
      if strcmp(formula.op{varIdx}, '+')
        ap_var = lookupTermName(formula.inputVars{1}, termPairs, 'ap');
        ap = fd_in{ap_var}(:);
        varIdx = varIdx+1;
      else
        error('Unconventional formula for hybrid sigma pressure coordinate!');
      end
    else
      a_var = lookupTermName(formula.inputVars{varIdx}, termPairs, 'a');
      a = fd_in{a_var}(:);
      varIdx = varIdx+1;
      p_ref_var = lookupTermName(formula.inputVars{varIdx}, termPairs, 'p0');
      p0 = fd_in{p_ref_var}(:);
      varIdx = varIdx+1;
      ap = a*p0;
    end
    b_var = lookupTermName(formula.inputVars{varIdx}, termPairs, 'b');
    b = fd_in{b_var}(:);
    varIdx = varIdx+1;
    ps_var = lookupTermName(formula.inputVars{varIdx}, termPairs, 'ps');
    ps = fd_in{ps_var}(:);
    pverFunc = @(tI, latI, lonI) ap + b*ps(tI, latI, lonI);
  case {'atmosphere_hybrid_height_coordinate'}
    a_var = lookupTermName(formula.inputVars{1}, termPairs, 'a');
    a = fd_in{a_var}(:);
    b_var = lookupTermName(formula.inputVars{2}, termPairs, 'b');
    b = fd_in{b_var}(:);
    orog_var = lookupTermName(formula.inputVars{3}, termPairs, 'orog');
    orog = fd_in{orog_var}(:);
    pverFunc = @(tI, latI, lonI) altitude2Pressure(a + orog(tI, latI, lonI)*b);
  otherwise,
    error('unknown vertical coordinate!');
end

for lonI = 1:nLon
  for latI = 1:nLat
    for tI = 1:nT
      this_p = pverFunc(tI, latI, lonI);
      % Use linear interpolation on log(p)
      data_regrided(tI, :, latI, lonI) = interp1(log(this_p), data(tI,:,latI, lonI), log(plev), 'linear');
    end
  end
end

fd_out{varName}(:) = data_regrided;
status = copyAtt(fd_out{varName}, fd_in{varName});
close(fd_out);
close(fd_in);

status = 0;
