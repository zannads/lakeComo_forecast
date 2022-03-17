% parse_benchmark
clear historical averageForecast cicloForecast conForecast
%%

fid = fopen( fullfile( raw_data_root, 'utils', 'Lake_Como_Data_1946_2019.txt' ) );
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
time = historical.Time(historical.Time>= DT_S);
n_t = length( time );
names = strcat( "agg_", string( std_aggregation) );

%% inflow aggregation
qAgg = aggregate_historical(time, historical.dis24(historical.Time>= datetime(1999,1,1)), std_aggregation );
qAgg = array2timetable( qAgg, 'RowTimes', time,'VariableNames', names );

%% AVERAGE
% repeat the same value everywhere and use it over all lead times.
data = mean( historical.dis24 )*ones( n_t, 1 );

averageForecast = forecast( time, data, ...
        'LeadTime', inf, 'EnsembleNumber', 1, 'Benchmark', true, ...
        'Name', "average" );

%% CICLOSTATIONARY
cs = moving_average( historical  ); %filter noise
%cs = historical( :, "dis24" );       %not noise filtered
cs = ciclostationary( cs  ); %get one realization(365 d) of ciclostationary mean

% get a time series starting from historical. 
cs = cicloseriesGenerator( cs, time );
data = cat(3, cs.dis24, cs.var24 );

cicloForecast = forecast( time, data, ...
    'LeadTime', nan, 'EnsembleNumber', inf, 'Benchmark', true, ...
        'Name', "ciclostationary" );

                
%% consistency
con_step = [1; 3; 7; 30]; %days
names = strcat( "ave_", string( con_step ), "d" );
conForecast(length(con_step)) = forecast;

% I start from a ciclostationary, so that where I can't
% fill I use ciclostationary mean already.
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
clear aggT con_step cs data h idx n_t names time