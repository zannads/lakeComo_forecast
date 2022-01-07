%LOAD_DETERMINISTIC_FORECAST
clear detForecast 
%Using the import tool, data is saved as
% deterministic_forecast 
deterministic_forecast  = readtable( fullfile( raw_data_root, 'PROGEA', 'forecast_progea_postProcManzoni.xlsx' ) );
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

% first day is 29 May 2014
first_day = datetime( 2014, 05, 29 );
time = (0:size( deterministic_forecast, 1)-1)' + first_day;
% lastday is 08 October 2020
% I need to add 1 day to format it to the forecast way i.e. the first value
% has to be Lead0.
time = time+1;
data = deterministic_forecast{:, 2:4};
detForecast = forecast( time, data, ...
        'LeadTime', 3, 'EnsembleNumber', 1, 'Benchmark', false, ...
        'Name', "PROGEA" );

clear deterministic_forecast first_day time data