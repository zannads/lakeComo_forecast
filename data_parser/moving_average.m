function historical = moving_average( historical, w)
    % moving average h = moving_average( q ) generates a timetable object in
    % the same period of q with a moving average window of +-5 steps. 
    %       h = moving_average( q, w )  generates a timetable object in
    % the same period of q with a moving average window of +-w steps.
    
if ~istimetable( historical )
    error( 'TimeSeries:wrongInput', ...
        'The input must be a timetable object.' );
end
if nargin < 2 
    w = 5;
end

%% start moving average
stream = historical{:, :};
[n_days, n_ex] = size( stream );
n_periods = floor(n_days/365); %number of full periods

% I extract the average of the w days before and at the end, to extend the
% time series so that I can have a moving average also for the first w
% days. 
pre  = zeros( w, n_ex);
preSD = 365-w;
post = zeros( w, n_ex);
postSD = n_days-365*n_periods;
for idx = 1:w
    pre(idx, :)  = mean( stream( (preSD +idx):365:n_days,   : ), 1 );
    post(idx, :) = mean( stream( (postSD+idx):365:n_days-w, : ), 1 );
end
temp = [pre; stream; post];
% Now temp is an extend stream of size [2w+n_days, n_ex]

for idx = 1:n_days
    % using temp this is the same of doing 
    % stream(idx) = stream( idx-w:idx+w );
    stream(idx, :) = mean( temp( idx:(idx+2*w), : ), 1 ) ;
end

historical{:,:} = stream;
end