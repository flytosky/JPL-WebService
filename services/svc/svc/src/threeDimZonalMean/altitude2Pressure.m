function p = altitude2Pressure(altitude)
%
% usage: p = altitude2Pressure(altitude)
%
% This function converts altitude to pressure by interpolating a table.
%
% Input:
%   altitutde	-- height in km above ground
%
% Output:
%   p		-- atmospheric pressure at the specified alttitude (hPa,mbar)
%

persistent p0;
persistent h0;
persistent h0logp0Interp;

if isempty(p0) | isempty(h0)
  h0 = [25.307,  24.240,  23.020,  22.004,  20.836,  19.855,  18.727,  17.773,  17.243,  16.753,  ...
 16.222,  15.731,  15.198,  14.706,  14.170,  13.674,  13.134,  12.633,  12.086,  11.578, ...
 11.021,  10.505,   9.938,   9.411,   8.848,   8.324,   7.947,   7.587,   7.241,   6.910, ...
  6.591,   6.283,   5.985,   5.698,   5.419,   5.149,   4.886,   4.631,   4.382,   4.140, ...
  3.904,   3.673,   3.448,   3.228,   3.084,   2.941,   2.801,   2.663,   2.527,   2.392, ...
  2.259,   2.128,   1.999,   1.871,   1.769,   1.669,   1.594,   1.520,   1.447,   1.374, ...
  1.301,   1.229,   1.157,   1.086,   1.016,   0.945,   0.875,   0.806,   0.737,   0.669, ...
  0.601,   0.533,   0.466,   0.399,   0.332,   0.266,   0.201,   0.135,   0.071,   0.006  ];
  p0 = [24.080,  28.368,  34.272,  40.175,  48.282,  56.388,  67.450,  78.512,  85.439,  92.366, ...
100.514, 108.663, 118.250, 127.837, 139.115, 150.393, 163.661, 176.930, 192.583, 208.236, ...
226.723, 245.210, 267.025, 288.841, 313.844, 338.848, 357.850, 376.851, 395.862, 414.873, ...
433.897, 452.921, 471.952, 490.984, 510.023, 529.062, 548.105, 567.147, 586.197, 605.247, ...
624.298, 643.348, 662.403, 681.458, 694.163, 706.869, 719.574, 723.279, 744.984, 757.690, ...
770.398, 783.106, 795.814, 808.522, 818.689, 828.856, 836.481, 844.107, 851.732, 859.358, ...
866.984, 874.610, 882.236, 889.862, 897.488, 905.114, 912.741, 920.367, 927.994, 935.621, ...
943.247, 950.874, 958.501, 966.128, 973.755, 981.382, 989.009, 996.636,1004.225,1011.814 ];
  h0logp0Interp = interp1(h0, log(p0), 'linear', 'pp');
end

p = exp(ppval(h0logp0Interp, altitude));