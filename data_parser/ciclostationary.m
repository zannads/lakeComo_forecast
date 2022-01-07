function ciclo = ciclostationary( historical )

%%
if ~istimetable( historical )
    error( 'TimeSeries:wrongInput', ...
        'Error. \nThe input must be a Time Series object.' );
end
if size( historical, 1 )< 365*2
    error( 'TimeSeries:wrongInput', ...
        'Error. \nThe input must be at least 2 years long.' );
end
%% leap day handling
isLeapDay = month(historical.Time)==2 & day(historical.Time)==29; 
%save leap day 
stream = historical.dis24;
% average with 28th februarys
stream( [isLeapDay(2:end-1);false]) = ...
    (stream( [isLeapDay(2:end-1);false] ) + stream( isLeapDay ) )/2;
% remove leap days. 
stream(isLeapDay,:) = [];  
Time = historical.Time( ~isLeapDay );

%% ciclostationary mean calculation
n_days = length( stream );
ciclo = zeros(365, 2);
for idx = 1:365
   pf = fitdist( stream( idx:365:n_days ), 'Normal' );
   ciclo( idx, 1 ) = pf.mu;
   ciclo( idx, 2 ) = pf.sigma^2;
end

ciclo = array2timetable( ciclo, 'RowTimes', Time(1:365), 'VariableNames', {'dis24', 'var24'} );
ciclo = sortrows( ciclo );

end