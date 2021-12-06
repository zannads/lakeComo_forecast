% parse_benchmark
clear averageDetForecast cicloDetForecast conDetForecast h
%%

% first day is 1 january 2000
first_day = datetime( 2000, 1, 1 );

fid = fopen('/Users/denniszanutto/Documents/Data/Short_term_forecast/comoInflow_ext.txt');
tline = string.empty;
while ~feof(fid)
tline(end+1) = fgetl(fid); %#ok<SAGROW>
end
fclose(fid);

h = str2double( tline );

%% for when I use comoInflow.txt
% tidx = 1;
% fidx = 1;
% while fidx <= length(tline) 
%     [y, m, d] = ymd( first_day+tidx-1 );
%     
%     if mod(y, 4) == 0 & m == 2 & d == 29
%         h(tidx) = (str2double(tline(fidx))+str2double(tline(fidx-1)))/2;
%     else
%         h(tidx) = str2double( tline(fidx) );
%         fidx = fidx+1;
%     end
%     tidx = tidx+1;
% end
  
%%
historical = timetable( h', 'TimeStep', days(1), 'StartTime', first_day, 'VariableNames', {'dis24'} );

hAgg = aggregate_historical(historical, std_aggregation );    

clear first_day tidx tline fid y m d fidx h
%% help 
l = length( historical.Time);
l_agg = length( std_aggregation );
names = strcat( "agg_", string( std_aggregation) );
%% AVERAGE

% repeat the same value everywhere
value = mean( historical.dis24 );
aggSeries = repmat( value, l,   l_agg);

averageDetForecast = array2timetable(aggSeries, ...
    'RowTimes', historical.Time, 'VariableNames', names );

%% CICLOSTATIONARY

cs = moving_average( historical  ); %filter noise
cs = ciclostationary( cs  ); %get one realization(365 d) of ciclostationary mean

% get a time series starting from historical.
b = cicloseriesGenerator( cs, [historical.Time; (historical.Time(end):caldays(1):historical.Time(end)+calyears(1))'] );
                
aggSeries = zeros( l, l_agg );
for aggT = 1:l_agg
    for tdx = 1:l
        tr = timerange( b.Time(tdx), b.Time(tdx)+std_aggregation(aggT) );
        c = b(tr, 1);
        
        aggSeries( tdx, aggT ) = mean( c.(1) );
    end
end

cicloDetForecast = array2timetable(aggSeries, ...
    'RowTimes', historical.Time, 'VariableNames', names );

                
%% consistency
con_step = [caldays([1; 3; 7; 14; 21]); calmonths(1)];
names = strcat( "ave_", string( con_step ) );

% I start from a ciclostationary, so that where I can't
% fill I use ciclostationary mean already.
aggSeries = repmat( cicloDetForecast.agg_1d, 1, length(con_step ) );
for aggT = 1:length(con_step)
    %for consistency you use the last agg_time elements, so I
    %search where to start.
    st_date = historical.Time(1)+con_step(aggT);
    st_idx = find(historical.Time == st_date, 1, 'first');
    
    
    % move from st_idx to the end.
    jdx = 1;
    for idx = st_idx:l
        t = historical.(1);
        aggSeries(idx, aggT) = mean( t(jdx:idx-1) );
        jdx = jdx+1;
    end
end

conDetForecast = array2timetable(aggSeries, ...
    'RowTimes', historical.Time, 'VariableNames', names );

clear aggSeries jdx idx st_idx aggT l l_agg names cs b c st_date tdx tr value t con_step