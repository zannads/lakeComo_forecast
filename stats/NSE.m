function outputArg = NSE( s, o, varargin)
%NSE - Nash Sutcliffe Efficiency score
%   n = NSE( s, o ) computes the Nash Sutcliffe Efficiency score.
%   The output n is a struct with the score in the first field. 
%   The other fields are the usual decomposition A, B, C.
%   n = NSE( s, o, 'Standard' ) behaves like n = NSE( s, o ).
%   n = NSE( s, 0, 'Modified' ) creates an output with fields:
%   -nse
%   -r
%   -alpha
%   -beta_n
% This names are defined accordingly to Gupta Klint 2009.

%% PARSE INPUT
% To decide which parameter to return and confirm the matching of the
% time series.
default_out = 'Standard';

if nargin>2
    if strcmp( 'Modified', varargin{1} )
        default_out = 'Modified';
    elseif ~strcmp( 'Standard', varargin{1} )
        warning( 'Last input not recognised. Standard output is used.' );
    end
end

% check they are the same lenght and the correct type.
if ~istimetable(s) || ~istimetable(o)
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