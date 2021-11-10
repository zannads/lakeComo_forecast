%LOAD_DETERMINISTIC_FORECAST
clear historical detForecast averageDis24 cicloDetForecast consistencyDetForecast
%Using the import tool, data is saved as
% deterministic_forecast 
deterministic_forecast  = readtable( fullfile( raw_data_root, 'Short_term_forecast', 'forecast_progea_postProcManzoni.xlsx' ) );
deterministic_forecast = renamevars( deterministic_forecast, ...
    deterministic_forecast.Properties.VariableNames, ...
    {'historical', 'lead1', 'lead2', 'lead3', 'subs'} );

% Data is a table with the following columns in m^3/s:
%   1. historical: historical inflow (at 8 am, average of the 24 hours
% before, in Fuentes???)
%   2. lead1: determinstic prevision, lead time 24 
%   3. lead2: determinstic prevision, lead time 48
%   4. lead3: determinstic prevision, lead time 72 ( made by a prevision on 12
%   only hour)
%   5. subs: number of hours where prevision is based only on
%   ciclo-stationary mean

% first day is 30 May 2014
first_day = datetime( 2014, 05, 30, 08, 00, 00 );
% lastday is 09 October 2020

% create the class
historical = timetable( deterministic_forecast.historical, 'TimeStep', days(1) );
historical.Properties.StartTime = first_day;
historical.Properties.VariableNames{1} = 'dis24';
% TODO add further information

% create the class
detForecast = timetable( deterministic_forecast.lead1, deterministic_forecast.lead2, deterministic_forecast.lead3, 'TimeStep', days(1) );
detForecast.Properties.StartTime = first_day;
detForecast.Properties.VariableNames = {'Lead1', 'Lead2', 'Lead3' };

detForecast = addprop( detForecast, {'kge', 'r', 'alpha', 'beta', 'kge_mod', 'gamma'}, ...
    {'variable', 'variable', 'variable', 'variable', 'variable', 'variable'} );

%% benchmarks 
%AVERAGE
meanDis24Historical = mean( historical.dis24 );
t = size( historical, 1);
averageDetForecast = timetable( historical.Time, ...
    meanDis24Historical*ones( t,1), meanDis24Historical*ones( t,1), ...
    meanDis24Historical*ones( t,1) );
averageDetForecast.Properties.VariableNames = {'Lead1', 'Lead2', 'Lead3'};
averageDetForecast = addprop( averageDetForecast, {'kge', 'r', 'alpha', 'beta', 'kge_mod', 'gamma'}, ...
    {'variable', 'variable', 'variable', 'variable', 'variable', 'variable'} );


%CICLOSTATIONARY
w = 5;
cicloDetForecast = historical;
temp =  historical.dis24;
for idx = 1+w:size( detForecast, 1 )-w
    cicloDetForecast.dis24(idx) = mean( temp(idx-w:idx+w) );
end
cicloDetForecast =  ciclostationary( cicloDetForecast  );
cicloDetForecast.(2) = cicloDetForecast.(1);
cicloDetForecast.(3) = cicloDetForecast.(1);
cicloDetForecast.Properties.VariableNames = {'Lead1', 'Lead2', 'Lead3'};
cicloDetForecast = addprop( cicloDetForecast, {'kge', 'r', 'alpha', 'beta', 'kge_mod', 'gamma'}, ...
    {'variable', 'variable', 'variable', 'variable', 'variable', 'variable'} );
%prop are already in

%CONSISTENCY 
consistencyDetForecast = timetable( historical.Time, ...
    [meanDis24Historical; historical.dis24(1:end-1)], ...
    [meanDis24Historical; historical.dis24(1:end-1)], ...
    [meanDis24Historical; historical.dis24(1:end-1)] );

consistencyDetForecast.Properties.VariableNames = {'Lead1', 'Lead2', 'Lead3' };
consistencyDetForecast = addprop( consistencyDetForecast, {'kge', 'r', 'alpha', 'beta', 'kge_mod', 'gamma'}, ...
    {'variable', 'variable', 'variable', 'variable', 'variable', 'variable'} );

%%
figure;
plot( historical.Time, historical.dis24 );
hold on; 
plot( averageDetForecast.Time, averageDetForecast.Lead1 );
plot( cicloDetForecast.Time, cicloDetForecast.Lead1 );
plot( consistencyDetForecast.Time, consistencyDetForecast.Lead1 );
legend( 'History', 'Average', 'ciclo', 'consistency' );

%%
clear first_day deterministic_forecast meanDis24Historical w idx t temp