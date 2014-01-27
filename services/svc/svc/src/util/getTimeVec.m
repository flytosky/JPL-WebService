function [years, months, indices] = getTimeVec(fileName)
%
% This function extracts the time points from the specified
% cmip5 netcdf data file using the calendar attributes and units
%
%

ts = ncread(fileName, 'time');
if hasAttribute(fileName, 'time', 'calendar')
  cal = ncreadatt(fileName, 'time', 'calendar');
else
  cal = 'gregorian';
  warning('!!! no calendar attribute, using Gregorian!');
end
unitsSpec = ncreadatt(fileName, 'time', 'units');

date0 = sscanf(unitsSpec, 'days since %d-%d-%d');
[years, months, indices] = convertDaysFromADateToMonths(date0, ts, cal);

