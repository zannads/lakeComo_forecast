function [kge, d1, d2, d3] = KGE( s, o, varargin)
%KGE - Kling Gupta Efficiency

%% PARSE INPUT
% To decide which parameter to return and confirm the matching of the
% time series.
default_out = 'Standard';

if nargin>2
    if strcmp( 'New', varargin{1} )
        default_out = 'New';
    elseif ~strcmp( 'Standard', varargin{1} )
        warning( 'Last input not recognaised. Standard output is used.' );
    end
end

% check they are the same lenght and the correct type.
if ~strcmp( class(s), class(time_series) ) || ~strcmp( class(o), class(time_series) )
    error( 'TimeSeries:wrongInput', ...
        'Error. \nThe input must be a Time Series object.' );
end
if ~isequal( s.date, o.date )
    error( 'TimeSeries:wrongInput', ...
        'Error. \nThe input must be defined in the same time period.' );
end

%% CALCULATION OF KGE
[~, A, B, C, r, alpha, beta] = NSE_( s.series, o.series );

ED = sqrt( (r-1)^2 + (alpha-1)^2 + (beta-1)^2 );
kge = 1-ED;

if strcmp( default_out, 'Standard' )
    d1 = A;
    d2 = B;
    d3 = C;
else
    %now it can only be New
    d1 = r;
    d2 = alpha;
    d3 = beta;
end

end