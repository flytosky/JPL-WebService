function plev = readPressureLevels(fd, plevVarName)

if strcmp(plevVarName, 'plev')
  plev = fd{'plev'}(:);
  switch lower(fd{'plev'}.units)
    case {'dbar', 'decibar'},
      plev = plev * 1e6; % convert from dbar to Pa
    case 'bar',
      plev = plev * 1e5; % convert from bar to Pa
    case {'milibar', 'mbar', 'hPa'},
      plev = plev * 1e2; % convert from mbar to Pa
    otherwise,
      %% don't do anything
  end
else
  switch lower(fd{'lev'}.units)
    case 'm',
      plev = altitude2Pressure(fd{'lev'}(:)/1000)*100; % m -> Km -> hPa -> Pa
  
    otherwise,
      p0 = 1.013e5; % 1atm = 1.013e5 Pa
      plev = fd{'lev'}(:)*p0;
  end
end
