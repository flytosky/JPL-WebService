function [x_opt, y_opt, z_opt] = decodeDisplayOpt(dispOpt)
%
%
%
x_opt = mod(dispOpt,2);
dispOpt = floor(dispOpt/2);
y_opt = mod(dispOpt,2);
dispOpt = floor(dispOpt/2);
z_opt = mod(dispOpt,2);
