function historical = moving_average( historical, varargin)
if ~strcmp( class(historical), class(timetable) ) 
    error( 'TimeSeries:wrongInput', ...
        'Error. \nThe input must be a Time Series object.' );
end
% TODO: handle w and varargin

%% start moving average
stream = historical.dis24;
n_days = length( stream );
n_periods = floor(n_days/365); %number of full periods
w = 5;

% estraggo la media dei due giorni prima dell inizio e la media dei due giorni dopo la fine
pre = zeros( w,1);
preSD = 365-w;
post = zeros( w,1);
postSD = n_days-365*n_periods;
for idx = 1:w
    pre(idx) = mean( stream( (preSD+idx):365:n_days ) );
    post(idx) = mean( stream( (postSD+idx):365:n_days-w ) );
end
temp = [pre; stream; post];

for idx = 1:size( stream, 1 )
    stream(idx) = mean( temp( idx:(idx+2*w) ) ) ;
end

historical.dis24 = stream;
end