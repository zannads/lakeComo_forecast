function historical = aggregate_historical( historical, agg_times )
if ~istimetable(historical)
    error( 'TimeSeries:wrongInput', ...
        'Error. \nThe input must be a Time Series object.' );
end
if ~iscalendarduration(agg_times)
    error( 'TimeSeries:wrongInput', ...
        'Error. \nThe aggregation time must be at least 1 and a calendar duration.' );
end
l = length(historical.Time);
support = nan( l, length(agg_times));
for jdx = 1:length(agg_times)
    %if agg_times(jdx)>caldays
    idx = 1;
    t = length(historical.Time);
    while idx<= t & idx
        %disp(idx);
        st = historical.Time(idx);
        if st+agg_times(jdx)-1 <= historical.Time(end)
            tr = timerange( st, st+agg_times(jdx));
            extracted_values = table2array( timetable2table(...
                historical(tr, 1 ), 'ConvertRowTimes', false ) );
            support(idx, jdx) =  mean( extracted_values );
            idx = idx+1;
        else
            idx = 0;
        end
    end
end
name = strcat( "agg_", string( agg_times )' );
support = array2timetable( support, 'RowTimes', historical.Time );
support.Properties.VariableNames = cellstr( name );
historical = [historical, support];
end