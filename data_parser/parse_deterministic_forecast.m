%% parse_deterministic_forecast
% Create the forecast object starting from the raw data in xlsx
% The data must be in the following path:
%   raw_data_root/type/forecast_...
% where type = PROGEA and forecast_.. name of the file

%% load data from Manzoni thesis (deprecated) 
% Few information are available about the production of this data, moreover
% the technique used to fill in the data (cyclostationary
% mean) is not advisable, consistency should be preferred at such short
% lead times.
clear detForecast 
global data_folder;

deterministic_forecast  = readtable( fullfile( data_folder, 'LakeComoRawData', 'PROGEA', 'forecast_progea_postProcManzoni.xlsx' ) );
deterministic_forecast = renamevars( deterministic_forecast, ...
    deterministic_forecast.Properties.VariableNames, ...
    {'historical', 'lead1', 'lead2', 'lead3', 'subs'} );

% Data is a table with the following columns in m^3/s:
%   1. historical: historical inflow (at 8 am, average of the 24 hours
% before)
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
detForecast.description = "PROGEA forecast with 24h time step, reconstructed using ciclostationary";

clear deterministic_forecast first_day time data

%% load data from AF 
% This are the same forecast as above, but when data are missing they are
% filled with consistency.
clear detForecast
deterministic_forecast  = readtable( fullfile( data_folder, 'LakeComoRawData', 'PROGEA', 'Fcst_Aggr_d_PROGEA_P_20140530_20220131_8h_FS_AF.csv' ) );
deterministic_forecast = renamevars( deterministic_forecast, ...
    deterministic_forecast.Properties.VariableNames, ...
    {'Time', 'lead1', 'lead2', 'lead3'} );

% Data is a table with the following columns in m^3/s:
%   1. time
%   2. dis24 with lead1d(lead24h): deterministic forecast, river discharge
%   in the last 24h, at 24h ahead time
%   3. lead2: determinstic prevision, lead time 48, i.e. from 25 to 48
%   4. lead3: determinstic prevision, lead time 72 ( made by a prevision on 12
%   only hour)

%to match with efas I simply remove the 8 hour shift (even If I should
%aggregate with a different time step from the original data)
deterministic_forecast.Time = deterministic_forecast.Time - hours(8);
deterministic_forecast = table2timetable( deterministic_forecast );

PROGEAForecast = forecast( deterministic_forecast.Time, deterministic_forecast.Variables, ...
        'LeadTime', 3, 'EnsembleNumber', 1, 'Benchmark', false, ...
        'Name', "PROGEA" );
PROGEAForecast.description = "PROGEA forecast with 24h time step, reconstructed using consistency instead of ciclostationary";

clear deterministic_forecast 

%% load synthetic det forecast by A F
% These data where produced to extend the period of the PROGEA forecasts.
% Each file is a table with time (first dim) and n ensemble members
    % (second dim) for a different lead time (1-2-3)
data = [];
for idx = 1:3
    deterministic_forecast  = readtable( fullfile( data_folder, 'LakeComoRawData', 'PROGEA', 'synthetic_forecasts', ['Syn_Fcst_PROGEA_P_1999-01-01_2022-01-31_8h_Ens_51_LeadTime_', int2str(idx), 'd.csv'] ) );
    deterministic_forecast = table2timetable( deterministic_forecast );
    data = cat(3, data, deterministic_forecast.Variables);
    % concatenate time x ensemble x lead time
end
% rearrange as time x lead time x ensemble
data = permute( data, [1, 3, 2] );
SynPROGEAForecast = forecast( deterministic_forecast.date, data, ...
        'LeadTime', 3, 'Benchmark', false, ...
        'Name', "SynPROGEA" );

clear data deterministic_forecast