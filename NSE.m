function outputArg = NSE( s, o, varargin)
%NSE - Nash Sutcliffe Efficiency

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

%% CALCULATION OF NSE
params = detCoeff(  s.(1), o.(1) );

if strcmp( default_out, 'Standard' )
    outputArg.nse = params.A - params.B -params.C;
    outputArg.A = params.A;
    outputArg.B = params.B;
    outputArg.C = params.C;
else
    %now it can only be Modified
    outputArg.nse = params.A - params.B -params.C;
    outputArg.r = params.r;
    outputArg.alpha = params.alpha;
    outputArg.beta_n = params.beta_n;
end
end