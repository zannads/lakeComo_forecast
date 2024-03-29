%% parse_benchmark
% Create the forecast and timetable object starting from the raw data in
% the txt file
clear historical averageForecast cicloForecast conForecast
%% file with historical data of level, release and inflow
% inflow is obtained inverting the mass balance equation and it is the
% inflow in the next 24 h
global data_folder;
fid = fopen( fullfile( data_folder, 'LakeComoRawData', 'utils', 'Lake_Como_Data_1946_2019.txt' ) );
tline = string.empty;
%delete first row as it is only info.
fgetl(fid);
% read data
while ~feof(fid)
    % I don't know the lenght at priori
    tline(end+1, :) = fgetl(fid); %#ok<SAGROW>
end
fclose(fid);

h = str2double( split(tline) );
t = datetime( h(:,3), h(:,2), h(:,1) );
h = h(:, 4:end);

historical = array2timetable( h, 'RowTimes', t, ...
    'VariableNames', {'h', 'r', 'dis24'} );

clear h t tline fid 
%% help 
DT_S = datetime(1999,1,1);
time = historical.Time(historical.Time>= DT_S);
n_t = length( time );
names = strcat( "agg_", string( std_aggregation) );

%% inflow aggregation
qAgg = aggregate_historical(time, historical.dis24(historical.Time>= DT_S), std_aggregation );
qAgg = array2timetable( qAgg, 'RowTimes', time,'VariableNames', names );

%% AVERAGE
% repeat the same value everywhere and use it over all lead times.
data = mean( historical.dis24 )*ones( n_t, 1 );

averageForecast = forecast( time, data, ...
        'LeadTime', inf, 'EnsembleNumber', 1, 'Benchmark', true, ...
        'Name', "average" );

%% CICLOSTATIONARY
cs = moving_average( historical(:,"dis24") ); %filter noise
%cs = historical( :, "dis24" );       %not noise filtered
cs = ciclostationary( cs ); %get one realization(365 d) of ciclostationary mean of release

% get a time series starting from historical. 
cs = cicloseriesGenerator( cs, time );
data = cat(3, cs.(1), cs.(2) );

cicloForecast = forecast( time, data, ...
    'LeadTime', nan, 'EnsembleNumber', inf, 'Benchmark', true, ...
        'Name', "ciclostationary" );

                
%% consistency
con_step = [1; 3; 7; 30]; %days
names = strcat( "ave_", string( con_step ), "d" );
conForecast(length(con_step)) = forecast;

% I start from the historical so I don't have any problem going backward
for aggT = 1:length(con_step)
    
    h = historical.dis24( historical.Time >= time(1)-con_step( aggT ) );
    data = nan( n_t, 1);
    
    for idx = 1:n_t
        data( idx, :) = mean( h( (1:con_step(aggT))+idx-1 ) );
    end
    
    conForecast( aggT ) = forecast( time, data, ...
        'LeadTime', inf, 'EnsembleNumber', 1, 'Benchmark', true, ...
        'Name', names( aggT ) );
end

%%
clear aggT con_step cs data h idx n_t names time DT_S ans