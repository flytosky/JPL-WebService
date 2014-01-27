function flag = hasAttribute(fn, varName, attName)
%
% This function checks whether variable varName has attribute with name specified by attName in netcdf file fn
%
varInfo = ncinfo(fn, varName);

flag = prod(strcmp({varInfo.Attributes.Name}, attName)) > 0;
