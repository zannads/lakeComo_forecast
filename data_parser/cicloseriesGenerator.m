function outputArg = cicloseriesGenerator( ciclo, tseries )
% cicloseriesGenerator fill a time series with a ciclostationary behaviour.
%   q = cicloseriesGenerator( ciclo, time ) repeats the value contained in
%   ciclo for the values in time. 
%   ciclo must be a timetable of size [365, n_s];
%   time must be a time vector or a sequence of double represenign the doy
%   of size [n_t,1]
%   
%   q will have size [n_t,n_s], its type will be linked to the type of
%   tseries. If tseries is a datetime object, the output will be a
%   timetable with tseries as time, while if tseries is numeric the output
%   will be a numeric.
%%
if ~istimetable(ciclo) && ~isnumeric(ciclo)
    error( 'TimeSeries:wrongInput', ...
        'The input must be a Timetable or numeric object.' );
end
% make tseries a vertical array of size [n_t,1]
tseries = tseries(:);
if ~(isdatetime( tseries ) || (isnumeric( tseries ) && all(tseries>0 & tseries<366) ) )
    error( 'TimeSeries:wrongInput', ...
        'The input must be a datetime object or a numeric representing the doy.' );
end
if size( ciclo, 1 )~= 365
    error( 'TimeSeries:wrongInput', ...
        'The ciclostationary mean must be a sequence of 365 days.' );
    % I trust that it is in the right order, otherwise undefined behaviour
end

%%
% convert into numeric the inputs
if istimetable( ciclo )
    ciclo_ = ciclo{:, :};
else 
    ciclo_ = ciclo;
end

if isdatetime( tseries )
    tseries_ = myDOY( tseries );
else
    tseries_ = tseries;
end
% now that I have a vector with the indexes to extract from ciclo that is a
% numeric matrix.
outputArg = ciclo_( tseries_, :);

if isdatetime( tseries )
    if istimetable( ciclo )
        outputArg = array2timetable( outputArg, 'RowTimes', tseries, 'VariableNames', ciclo.Properties.VariableNames );
    else
        outputArg = array2timetable( outputArg, 'RowTimes', tseries );
    end
% else
%   outputArg is already a numeric type
end

end