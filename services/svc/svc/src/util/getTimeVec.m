function [years, months, indices] = getTimeVec(fileName)
%
% This function extracts the time points from the specified
% cmip5 netcdf data file using the calendar attributes and units
%
%

ts = ncread(fileName, 'time');
cal = ncreadatt(fileName, 'time', 'calendar');
unitsSpec = ncreadatt(fileName, 'time', 'units');

date0 = sscanf(unitsSpec, 'days since %d-%d-%d');
[years, months, indices] = convertDaysFromADateToMonths(date0, ts, cal);

