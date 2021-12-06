function outputArg = extractLT( forecast, lt )

if ~istimetable( forecast )
    error( 'not a timetable' );
end

p = forecast.Time(lt+1:end);
q = forecast.Variables;

q= q(1:end-lt, :);

outputArg = array2timetable(q, 'RowTimes', p);
