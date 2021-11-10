function ouptutArg = VE( s, o ) 

% check they are the same lenght and the correct type.
if ~strcmp( class(s), class(timetable) ) || ~strcmp( class(o), class(timetable) )
    error( 'TimeSeries:wrongInput', ...
        'Error. \nThe input must be a Time Series object.' );
end
if ~isequal( s.Time, o.Time )
    error( 'TimeSeries:wrongInput', ...
        'Error. \nThe input must be defined in the same time period.' );
end

ouptutArg = 1- sum( abs( s.(1)-o.(1) ) )/sum( o.(1) );
end