%LOAD_DETERMINISTIC_FORECAST
clear historical detForecast 
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
first_day = datetime( 2014, 05, 30 );
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

detForecast = addprop( detForecast, fieldnames(detStats), ...
    {'variable', 'variable', 'variable', 'variable', 'variable', 'variable', 'variable', 'variable'} );

clear deterministic_forecast first_day