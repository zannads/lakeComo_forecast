%LOAD_DETERMINISTIC_FORECAST

%Using the import tool, data is saved as
% deterministic_forecast 
deterministic_forecast  = readtable( strcat( raw_data_root, 'forecast_progea_postProcManzoni.xlsx' ) );
deterministic_forecast = renamevars( deterministic_forecast, ...
    deterministic_forecast.Properties.VariableNames, ...
    {'historical', 'lead1', 'lead2', 'lead3', 'subs'} );

% Data is a table with the following columns in m^3/s:
%   1. historical: historical inflow (at 8 am, average of the 24 hours
% before, in Fuentes???)
Fuentes = struct( 'Lon', 9.412760, 'Lat', 46.149950); 
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
historical = hist_series();
historical.name = "Historical inflow";
historical.description = "Historical inflow in Fuentes";
historical = historical.set_coordinate( Fuentes.Lon, Fuentes.Lat);

% populate
historical = set_series( historical, deterministic_forecast.historical );
historical = historical.set_date( first_day );

% create the class
detForecast = forecast_series();
detForecast.name = "Deterministic forecast";
detForecast.description = "Deterministic forecast inflow in Fuentes";
detForecast = detForecast.set_coordinate( Fuentes.Lon, Fuentes.Lat);

% populate
detForecast = set_series( detForecast, ...
    [deterministic_forecast.lead1, deterministic_forecast.lead2, deterministic_forecast.lead3] );
detForecast = detForecast.set_date( first_day );
detForecast = detForecast.set_lt();