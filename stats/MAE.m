function mae = MAE(s,o)
%MAE computes the Mean Absolute Error
%   Detailed explanation goes here
%% PARSE INPUT
% To decide which parameter to return and confirm the matching of the
% time series.

% check they are the same lenght and the correct type.
if ~istimetable(s) | ~istimetable(o)
    error( 'TimeSeries:wrongInput', ...
        'Error. \nThe input must be a Time Series object.' );
end
if ~isequal( s.Time, o.Time )
    error( 'TimeSeries:wrongInput', ...
        'Error. \nThe input must be defined in the same time period.' );
end

%%
mae = sum(abs( s.(1)-o.(1) ), 'all')/length( s.Time );
end

