function ciclo = ciclostationary( historical )

%%
if ~strcmp( class(historical), class(timetable) ) 
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

%% ciclostationary mean calculation
n_days = length( stream );
ciclo = zeros(365, 1);
for idx = 1:365
   ciclo( idx ) = mean( stream( idx:365:n_days ) );
end

ciclo = timetable( historical.Time(1:365), ciclo );
ciclo.Properties.VariableNames{1} = 'dis24';
ciclo.Time.Year( ciclo.Time.Year == 2015 ) = ciclo.Time.Year( ciclo.Time.Year == 2015 )-1;
ciclo = sortrows( ciclo );

end

%estraggo ogni singolo anno 
% riduco gli anni bisestili
% shifto tutti avanti fino all ultimo anno 
% interseco ottnendo tante colonne quanti anni
% riduco mediando tutte le colonne
% ricostruisco con la time series iniziale e se c'è il giorno bisestile uso
% il giorno prima