function ouptutArg = VE( s, o ) 
% VE Compute volumetric efficiency score.
%   v = VE( s, o ) computes the volumetric efficiency score for the
%   simulation timetable s and the observed timetable o.
%   
%   The volumetric efficiency score is computed accordingly to Criss_2008.

% check they are the same lenght and the correct type.
if ~istimetable(s) || ~istimetable(o)
    error( 'TimeSeries:wrongInput', ...
        'Error. \nThe input must be a Time Series object.' );
end
if ~isequal( s.Time, o.Time )
    error( 'TimeSeries:wrongInput', ...
        'Error. \nThe input must be defined in the same time period.' );
end

ouptutArg = 1- sum( abs( s.(1)-o.(1) ) )/sum( o.(1) );
end