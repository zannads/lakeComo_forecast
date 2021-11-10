function outputArg = KGE( s, o, varargin)
%KGE - Kling Gupta Efficiency

%% PARSE INPUT
% To decide which parameter to return and confirm the matching of the
% time series.
default_out = 'Standard';

if nargin>2
    if strcmp( 'Modified', varargin{1} )
        default_out = 'Modified';
    elseif ~strcmp( 'Standard', varargin{1} )
        warning( 'Last input not recognaised. Standard output is used.' );
    end
end

% check they are the same lenght and the correct type.
if ~strcmp( class(s), class(timetable) ) || ~strcmp( class(o), class(timetable) )
    error( 'TimeSeries:wrongInput', ...
        'Error. \nThe input must be a Time Series object.' );
end
if ~isequal( s.Time, o.Time )
    error( 'TimeSeries:wrongInput', ...
        'Error. \nThe input must be defined in the same time period.' );
end

%% CALCULATION OF KGE
params = detCoeff( s.(1), o.(1) );

if strcmp( 'Standard', default_out )
    ED = sqrt( (params.r-1)^2 + (params.alpha-1)^2 + (params.beta-1)^2 );
    outputArg.kge = 1-ED;
    outputArg.r = params.r;
    outputArg.alpha = params.alpha;
    outputArg.beta = params.beta;
else
    ED = sqrt( (params.r-1)^2 + (params.gamma-1)^2 + (params.beta-1)^2 );
    outputArg.kge = 1-ED;
    outputArg.r = params.r;
    outputArg.gamma = params.gamma;
    outputArg.beta = params.beta;
end
end