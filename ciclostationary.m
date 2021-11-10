function outputArg = ciclostationary( series )

if ~strcmp( class(series), class(timetable) ) 
    error( 'TimeSeries:wrongInput', ...
        'Error. \nThe input must be a Time Series object.' );
end

isLeapDay = month(series.Time)==2 & day(series.Time)==29; 
%save leap day 
%leapDays = series(isLeapDay, :);
stream = series.(1);
stream( [isLeapDay(2:end-1);false]) = ...
    (stream( [isLeapDay(2:end-1);false] ) + stream( isLeapDay ) )/2;
% remove leap days. 
stream(isLeapDay,:) = [];  
ciclo = zeros(365, 1);
n_days = length( stream );
%n_periods = n_days/365;
   
for idx = 1:365
   ciclo( idx ) = mean( stream( idx:365:n_days ) );
end

outputArg = zeros(size( series, 1), 1);
for idx = 1:length(outputArg)
    if month(series.Time(idx))==2 & day(series.Time(idx))==29 & idx>1
        outputArg(idx) = outputArg(idx-1);
    else
        outputArg(idx) = ciclo( mod( idx+364, 365 )+1 );
    end
end

outputArg = timetable( series.Time, outputArg );
end