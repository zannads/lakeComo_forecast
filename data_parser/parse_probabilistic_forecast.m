%LOAD PROBABILISTIC FORECAST
if ~exist( 'location', 'var' )
    location = LakeComo;
end
%% lets start with extended range: efrf
% get a list of object in the folder and remove all non NetCDF files 
efrfForecast = probForecast();
efrfForecast = efrfForecast.upload('efrf', location );

%% now its time for seasonal: efsr
efsrForecast = probForecast();
efsrForecast = efsrForecast.upload( 'efsr', location );

clear location