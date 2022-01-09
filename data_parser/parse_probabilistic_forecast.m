%LOAD PROBABILISTIC FORECAST
% lets start with extended range: efrf
efrfForecast = upload('efrf', locations );
%%
% now its time for seasonal: efsr
efsrForecast = upload( 'efsr', locations );

%% uploadOLD
%{
function obj = uploadOLD( type, location)
%UPLOAD uploads from the folder the EFAS forecast of one of the
%two types: efrf or efsr.

%% input parse
obj.location = location;

if strcmp( type, 'efrf_sub' )
    dis = 'dis06';
    agg = 4;
else
    dis = 'dis24';
    agg = 1;
end

%% upload
global raw_data_root;
% get a list of object in the folder and remove all non NetCDF files
list_element = dir( fullfile( raw_data_root, type , '*.nc') );

% get the number of ensambles.
ensamble_number = ncread( fullfile( raw_data_root, type, list_element(1).name ), 'number' );
ensamble_number = length( ensamble_number );
obj.ensembleN = ensamble_number;

% get the lead times
step = ncread( fullfile( raw_data_root, type, list_element(1).name ), 'step' );
obj.leadTime = step(end)/24;
names = strcat( 'Lead', string((1:obj.leadTime)') )';

%for each element in the folder,
% extract discharge
% extract the cell
% concatenate
obj.data = cell(1, ensamble_number);
for idx = 1:length( list_element )
    
    raw_data = ncread( fullfile( raw_data_root, type, list_element(idx).name ), dis );
    raw_data = squeeze( raw_data( location.r, location.c, :, :) );
    
    start_date = ncread( fullfile( raw_data_root, type, list_element(idx).name ), 'time' );
    start_date = datetime(1970, 1, 1) + seconds(start_date);
    
    raw_data = reshape ( raw_data(step>0, :), agg, [], ensamble_number); % in efrf we need to jump the LT= 0, thus start from 2.
    % reshape in 1st_dir:single_day, 2nd_dir:LT,
    % 3rd_dir:ensamble
    raw_data = squeeze( mean( raw_data, 1) );   % mean over the day
    
    for jdx = 1:ensamble_number
        newF = array2timetable( raw_data(:,jdx)', 'RowTimes', start_date, 'VariableNames', names); % in efsr Lt=0 is not selected
        obj.data{jdx} = [obj.data{jdx}; newF];
    end
end
obj.daysN = size( obj.data{1}, 1 );
end
%}
%% uploadNEW
function obj = upload( type, location)
%UPLOAD uploads from the folder the EFAS forecast of one of the
%two types: efrf or efsr.

% input parse
dis = 'dis24';
global raw_data_root;
n_l = length( location );

obj(n_l)= forecast;
for loc = 1:n_l
    % upload
    % get a list of object in the folder and remove all non NetCDF files
    list_element = dir( fullfile( raw_data_root, type, location(loc).fname , '*.nc') );
    n_t = length( list_element );
    
    % get the number of ensambles.
    raw_data = ncread( fullfile( list_element(1).folder, list_element(1).name ), dis );
    raw_data = squeeze( raw_data );
    ensembleN = size(raw_data, 2);
    
    % get the lead times. dis24 is the discharge in the last 24 hours, thus the
    % lead at 24 hours of dis24 is actually the Lead0.
    leadTime = size(raw_data, 1);
    %names = strcat( 'Lead', string((1:leadTime)'-1) )';
    
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