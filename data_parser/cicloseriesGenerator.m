function outputArg = cicloseriesGenerator( ciclo, tseries )
% cicloseriesGenerator fill a time series with a ciclostationary behaviour.
%   q = cicloseriesGenerator( ciclo, time ) repeats the value contained in
%   ciclo for the values in time. 
%   ciclo must be a timetable of size 365xn;
%   time must be a time vector of at least 366 elements (to improve)
%%
if ~istimetable(ciclo)
    error( 'TimeSeries:wrongInput', ...
        'Error. \nThe input must be a Time Series object.' );
end
if size( tseries, 1 )< 365*2
    error( 'TimeSeries:wrongInput', ...
        'Error. \nThe input must be at least 2 years long.' );
end
if size( ciclo, 1 )~= 365
    error( 'TimeSeries:wrongInput', ...
        'Error. \nThe ciclostationary mean must be a sequence of 365 days.' );
    % I trust that it is in the right order
end

%%
outputArg = zeros( size(tseries, 1), 2 );
for idx = 1:size(tseries, 1)
    [y, m, d] = ymd( tseries(idx) );
    
    if mod(y, 4) == 0 & m==2 & d==29
        % if leap day use 28th of february and 1st march
        outputArg(idx, 1) = mean( ...
            [ciclo.dis24( ciclo.Time.Month == 2 & ciclo.Time.Day == 28 );
            ciclo.dis24( ciclo.Time.Month == 3 & ciclo.Time.Day == 1 )]...
            );
        outputArg(idx, 2) = ciclo.var24( ciclo.Time.Month == 2 & ciclo.Time.Day == 28 );
    else
        outputArg(idx, 1) = ciclo.dis24( ciclo.Time.Month == m & ciclo.Time.Day == d );
        outputArg(idx, 2) = ciclo.var24( ciclo.Time.Month == m & ciclo.Time.Day == d );
    end
end

outputArg = array2timetable( outputArg, 'RowTimes', tseries, 'VariableNames', {'dis24', 'var24'} );
end