function status = copyAtt(nc_to, nc_from)
%
% This function copies a variable from netcdf object "nc_from" to "nc_to"
%
status = -1;
attrb = ncatt(nc_from);
for ii = 1:length(attrb)
  att_name = ncname(attrb{ii});
  eval(['nc_to.' att_name ' = nc_from.' att_name ';']);
end
status = 0;
