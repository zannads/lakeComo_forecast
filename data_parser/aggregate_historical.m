function outputArg = aggregate_historical( time, data, agg_times )
    % aggregate_historical Forward aggregation of a time series.
    %   qAgg = aggregate_historical( time, q, agg_time ) is the time series q
    %   with values that are aggregated accordingly to agg_times. time and q
    %   must be vertical vectors (to improve)with n_t values, agg_times another
    %   vector of length n_a of type calendar duration or a numeric one, in
    %   that case the value will be parsed as days. qAgg will be a matrix of
    %   size n_t x n_a, filled with NaN when there are no future values to
    %   aggregate.
    
    % input check
    if ~isdatetime(time) || ~isvector( time )
        error( 'TimeSeries:wrongInput', ...
            'The input must be a Time Series object.' );
    end
    if ~isnumeric(data) || ~isvector( data )
        error( 'TimeSeries:wrongInput', ...
            'The input must be a Time Series object.' );
    end
    if ~( iscalendarduration(agg_times) || isnumeric(agg_times)) || ~isvector( agg_times ) 
        error( 'TimeSeries:wrongInput', ...
            'The aggregation time must be a vector of at least 1 element and a calendar duration type or a numeric value.' );
    end
    % data must be vertical and time too. 
    data = data(:);
    time = time(:);
    % agg_times horizontal 
    agg_times = agg_times(:)';
    
    % get a matrix n_t x n_a that for each day in time gives you how many days
    % you have to add for a given vector of aggregation times.
    agg_timeStep = days((time+agg_times)-time);
    [n_t, n_a] = size( agg_timeStep );
    
    outputArg = nan( n_t, n_a );
    % start iterating for each aggregation time
    for c = 1:n_a
        % Inner loop, I should iterate through all rows
        rs = 1:n_t; 
        % But, I need to remove from the iteration the rows for which I don't have
        % enough values to aggregate.
        rs( rs+ agg_timeStep(:, c)'-1 > n_t ) = []; 
        for r = rs
            outputArg( r, c) = mean( data(r:r+agg_timeStep(r,c)-1) );
        end
    end
end