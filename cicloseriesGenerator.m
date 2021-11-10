function historical = cicloseriesGenerator( ciclo, historical )

%%
if ~(strcmp( class(historical), class(timetable) ) & strcmp( class(ciclo), class(timetable) ) )
    error( 'TimeSeries:wrongInput', ...
        'Error. \nThe input must be a Time Series object.' );
end
if size( historical, 1 )< 365*2
    error( 'TimeSeries:wrongInput', ...
        'Error. \nThe input must be at least 2 years long.' );
end
if size( ciclo, 1 )~= 365
    error( 'TimeSeries:wrongInput', ...
        'Error. \nThe ciclostationary mean must be a sequence of 365 days.' );
    % I trust that it is in the right order
end

%%
year_c = ciclo.Time.Year(1);
for idx = 1:size(historical, 1)
    d = day(historical.Time(idx));
    m = month(historical.Time(idx));
    if m==2 & d==29 & idx>1
        % if leap day use 28th of february and 1st march
        t1 = strcat( num2str(year_c), '-',num2str(m), '-',num2str(d-1) ); 
        t1 = timerange( t1, 'days');
        t1 = ciclo( t1, : );
        t2 = strcat( num2str(year_c), '-',num2str(m+1), '-', '1' ); 
        t2 = timerange( t2, 'days');
        t2 = ciclo( t2, : );
        historical.dis24(idx) = mean(t1.dis24+t2.dis24);
    else
        t = strcat( num2str(year_c), '-',num2str(m), '-',num2str(d) ); 
        t = timerange( t, 'days');
        t = ciclo( t, : );
        historical.dis24(idx) = t.dis24;
    end
end
end