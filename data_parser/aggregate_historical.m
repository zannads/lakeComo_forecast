function outputArg = aggregate_historical( time, data, agg_times )
if ~isdatetime(time) || size( time,1 ) ~= size(data,1) || ~isvector( data )
    error( 'TimeSeries:wrongInput', ...
        'Error. \nThe input must be a Time Series object.' );
end
if ~iscalendarduration(agg_times)
    error( 'TimeSeries:wrongInput', ...
        'Error. \nThe aggregation time must be at least 1 and a calendar duration.' );
end
if size( agg_times, 1) > size( agg_times, 2) 
    agg_times = agg_times';
end

agg_timeStep = days((time+agg_times)-time);
[n_t, n_a] = size( agg_timeStep );

outputArg = nan( n_t, n_a, size( data, 2 ) );

for c = 1:n_a
    rs = 1:n_t;
    rs( rs+ agg_timeStep(:, c)'-1 > n_t ) = []; 
    for r = rs
        outputArg( r, c, :) = mean( data(r:r+agg_timeStep(r,c)-1), 1 );
    end
end
end