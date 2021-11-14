%LOAD PROBABILISTIC FORECAST
if ~exist( 'location', 'var' )
    location = ComoLake;
end
%% lets start with extended range: efrf
% get a list of object in the folder and remove all non NetCDF files 
list_element = dir( fullfile( raw_data_root, 'efrf' , '*.nc') );
ensamble_number = 10;

%for each element in the folder, 
    % extract ts 
    % extract the cell
    % concatenate 
efrfForecast = cell(1, ensamble_number);
for idx = 1:length( list_element )
    
    raw_data = ncread( fullfile( raw_data_root, 'efrf', list_element(idx).name ), 'dis06' );
    raw_data = squeeze( raw_data( location.r, location.c, :, :) );
    
    start_date = ncread( fullfile( raw_data_root, 'efrf', list_element(idx).name ), 'time' );
    start_date = datetime(1970, 1, 1) + seconds(start_date);
    
    for jdx = 1:ensamble_number
        %move from 6 to 24
        raw_data6 = raw_data(:, jdx)';
        raw_data24 = zeros(1, 46);
        for k = 1:46
            raw_data24(k) = mean( raw_data6(k:k+3) );
        end
        
         newF = array2timetable(raw_data24, 'RowTimes', start_date);
         efrfForecast{jdx} = [efrfForecast{jdx}; newF];
    end
end

clear  raw_data24 raw_data6
%% now its time for seasonal: efsr
% get a list of object in the folder and remove all non NetCDF files 
list_element = dir( fullfile( raw_data_root, 'efsr' , '*.nc') );
ensamble_number = 25;

%for each element in the folder, 
    % extract ts 
    % extract the cell
    % concatenate 
efsrForecast = cell(1, ensamble_number);
for idx = 1:length( list_element )
    
    raw_data = ncread( fullfile( raw_data_root, 'efsr', list_element(idx).name ), 'dis24' );
    raw_data = squeeze( raw_data( location.r, location.c, :, :) );
    
    start_date = ncread( fullfile( raw_data_root, 'efsr', list_element(idx).name ), 'time' );
    start_date = datetime(1970, 1, 1) + seconds(start_date);
    
    for jdx = 1:ensamble_number
         newF = array2timetable( raw_data(:,jdx)', 'RowTimes', start_date);
         efsrForecast{jdx} = [efsrForecast{jdx}; newF];
    end
end

efsrFdetStats.step = 7;
efsrFdetStats.agg_times = [1, efsrFdetStats.step:efsrFdetStats.step:size(efsrForecast{1},2)];


clear jdx idx k newF start_date raw_data ensamble_number list_element location