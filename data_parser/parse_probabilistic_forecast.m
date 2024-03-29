%% parse_probabilistic_forecast
% Create the forecast object starting from the raw data in NetCDF
% downloaded from EFAS. The data must be in the following path:
%   data_folder/LakeComoRawData/type/locationName/
% type is either 'efrf' Probabilistic reforecast or 'efsr' Prob Seasonal
% reforecast locationName was one of the 4 I downloaded, i.e. Fuentes,
% Samolaco, LakeComo, Olginate

% Important locations from the EFAS Domain
Fuentes = struct( 'Lon', 9.412760, 'Lat', 46.149950);
Fuentes.fname = "Fuentes";
Olginate = struct( 'Lon', 9.41338, 'Lat', 45.8053);
Olginate.fname = "Olginate";
LakeComo = struct( 'Lon', 9.38175, 'Lat', 45.853973);
LakeComo.fname = "LakeComo";
Mandello = struct( 'Lon', 9.310840, 'Lat', 45.904705); 
Mandello.fname = "Mandello";
locations = [Fuentes, Mandello, LakeComo, Olginate];
clear Fuentes Olginate LakeComo Mandello

% lets start with extended range: efrf
efrfForecast = uploadEFAS('efrf', locations );

% now its time for seasonal: efsr
efsrForecast = uploadEFAS( 'efsr', locations );

function obj = uploadEFAS( type, location)
%UPLOAD uploads from the folder the EFAS forecast of one of the
%two types: efrf or efsr.

% input parse
dis = 'dis24'; 
% Both the forecasts are both dis24 because the EFAS efrf that are
% originally in dis06 where preprocessed when downloading.
% Also the EFAS efsr are reduced to the same number of ensemble members.
global data_folder;
n_l = length( location );

obj(n_l)= forecast; %preallocate
for loc = 1:n_l
    % upload
    % get a list of object in the folder and remove all non NetCDF files
    list_element = dir( fullfile( data_folder, 'LakeComoRawData', type, location(loc).fname , '*.nc') );
    n_t = length( list_element );
    
    % get the number of ensambles.
    raw_data = ncread( fullfile( list_element(1).folder, list_element(1).name ), dis );
    raw_data = squeeze( raw_data );
    ensembleN = size(raw_data, 2);
    
    % get the lead times. dis24 is the discharge in the last 24 hours, thus the
    % lead at 24 hours of dis24 is actually the inflow in the next 24 at Lead0.
    leadTime = size(raw_data, 1);
    
    %for each element in the folder,
    % extract discharge
    % concatenate
    data = nan( n_t, leadTime, ensembleN );
    time = NaT( n_t, 1);
    for idx = 1:length( list_element )
        
        raw_data = ncread( fullfile( list_element(idx).folder, list_element(idx).name ), dis );
        data(idx, :, :) = raw_data;
        
        start_date = ncread( fullfile( list_element(idx).folder, list_element(idx).name ), 'time' );
        time(idx) = datetime(1970, 1, 1) + seconds(start_date);
        
    end
    
    obj(loc) = forecast( time, data, ...
        'LeadTime', leadTime, 'EnsembleNumber', ensembleN, 'Benchmark', false, ...
        'Name', location(loc).fname );
end
end