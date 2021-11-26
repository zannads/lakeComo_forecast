function support = aggregate_forecast( forecast, agg_time )
if ~istimetable(forecast) 
    error( 'TimeSeries:wrongInput', ...
        'Error. \nThe input must be a Time Series object.' );
end
if agg_time < 1
    error( 'TimeSeries:wrongInput', ...
        'Error. \nThe aggregation time must be at least 1.' );
end

% create the timetable with the time I want
support = timetable;
for idx = 1:length( forecast.Time )-1
    gap_time = forecast.Time(idx+1)-forecast.Time(idx) ;
    missed_dates = ceil( days(gap_time-1)/agg_time );
    gap_time = agg_time*missed_dates;
    
    extracted_values = table2array( timetable2table(...
        forecast(idx, 1:gap_time ), 'ConvertRowTimes', false ) )';
    
    aggregated_values = zeros(missed_dates , 1 );
    for jdx = 1:length( aggregated_values )
        aggregated_values( jdx ) = mean( extracted_values( (jdx-1)*agg_time+1:jdx*agg_time ) );
    end
    
    % add to time array the times
    support = [support; ...
        timetable(...
        (forecast.Time(idx):days(agg_time):forecast.Time(idx)+days(gap_time-1))',...
        aggregated_values ) ] ; %#ok<AGROW>
    
end

%now for the last month using calmonths
gap_time = (forecast.Time(end)+calmonths)-forecast.Time(end) ;
missed_dates = ceil( days(gap_time-1)/agg_time );
gap_time = agg_time*missed_dates;

extracted_values = table2array( timetable2table(...
    forecast(end, 1:gap_time ), 'ConvertRowTimes', false ) )';

aggregated_values = zeros(missed_dates , 1 );
for jdx = 1:length( aggregated_values )
    aggregated_values( jdx ) = mean( extracted_values( (jdx-1)*agg_time+1:jdx*agg_time ) );
end

% add to time array the times
support = [support; ...
    timetable(...
    (forecast.Time(end):days(agg_time):forecast.Time(end)+days(gap_time-1))',...
    aggregated_values ) ] ; 

if agg_time == 1
    support.Properties.VariableNames{1} = 'dis24';
else
    support.Properties.VariableNames{1} = strcat( 'agg', num2str( agg_time ) );
end
end