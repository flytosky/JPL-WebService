function ha = displayTwoDimData(lon, lat, twoDimData, ha, cfgParams)
%
% This function displays two dimensional data (longitude x latitude)
% overlaying on top of a coastal line.
%
persistent coastData;

if isempty(coastData)
  coastLongAndLat = load('data/coastLineData.txt');
  coastLongAndLat = reshape(coastLongAndLat, [], 2);
end

if nargin < 5
if nargin < 4
figure;
ha = gca;
end
xlabelOff = false;
ylabelOff = false;
else
  xlabelOff = cfgParams.xlabelOff;
  ylabelOff = cfgParams.ylabelOff;
end
imagesc(lon, -lat, twoDimData');colorbar;
hold on;
plot(ha, coastLongAndLat(:,2)-360, -coastLongAndLat(:,1), 'k-');
plot(ha, coastLongAndLat(:,2), -coastLongAndLat(:,1), 'k-');
plot(ha, coastLongAndLat(:,2)+360, -coastLongAndLat(:,1), 'k-');
set(ha, 'fontsize', 13);
set(ha, 'yTickLabel', num2strNoNegZero(-get(gca, 'yTick')'));
if ~xlabelOff
  xlabel(ha, 'longitude(deg)');
end
if ~ylabelOff
  ylabel(ha, 'latitude(deg)');
end
