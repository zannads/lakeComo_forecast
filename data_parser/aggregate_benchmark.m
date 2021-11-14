function outputArg = aggregate_benchmark(forecast, benchmark, agg_time, varargin)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
if ~(strcmp( class(forecast), class(timetable) ) & strcmp( class(benchmark), class(timetable) ) )
    error( 'TimeSeries:wrongInput', ...
        'Error. \nThe input must be a Time Series object.' );
end
if agg_time < 1
    error( 'TimeSeries:wrongInput', ...
        'Error. \nThe aggregation time must be at least 1.' );
end
default_dir = true;
if nargin > 3 & strcmp(varargin{1}, 'backward' )
    default_dir = false;
end

% % reduce the times to match the sizes
% ideally benchamrks are always extracted from historical data, that are
% longer and also daily..
% start_time = max( forecast.Time(1), benchmark.Time(1) );
% end_time = min( forecast.Time(end), benchmark.Time(end) );
% mask = forecast.Time>= start_time & forecast.Time <= end_time;
% forecast = forecast( mask, :);
% benchmark = benchmark.Time>= start_time & benchmark.Time <= end_time;
% benchmark = benchmark( mask, :);

outputArg = forecast;
t = size( forecast, 1) ;
idx = 1;
while idx <= t
    d = outputArg.Time(idx);
    
    if default_dir
        if ~(d+agg_time>benchmark.Time(end))
            extracted_values = table2array( timetable2table(...
                benchmark(d:d+agg_time-1, 1 ), 'ConvertRowTimes', false ) );
            
            outputArg(idx, 1) = {mean( extracted_values )};
        else
            outputArg(idx:end, :) = [];
            idx = t;
        end
    else
        c1 = d-agg_time<benchmark.Time(1);
        c2 = d> benchmark.Time(end);
        if ~( c1 | c2 )
            extracted_values = table2array( timetable2table(...
                benchmark(d-agg_time+1:d, 1 ), 'ConvertRowTimes', false ) );
            
            outputArg(idx, 1) = {mean( extracted_values )};
        else
            if c1
                outputArg(idx, :) = [];
                idx = idx-1;
            end
            if c2
                outputArg(idx:end, :) = [];
                idx = t;
            end
        end
        
    end
    
    idx = idx+1;
end

