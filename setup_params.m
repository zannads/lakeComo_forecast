%ADD PATHS AND CONSTANTS

global raw_data_root;
raw_data_root = '/Users/denniszanutto/Documents/Data';
addpath( raw_data_root );

Fuentes = struct( 'Lon', 9.412760, 'Lat', 46.149950); 
Fuentes.r = 45;
Fuentes.c = 33;
Olginate = struct( 'Lon', 9.41338, 'Lat', 45.8053); 
Olginate.r = 45;
Olginate.c = 40;

% process_data_root = fullfile( matlabdrive, 'lakeComoForecastData' );
% addpath( process_data_root );

path_ = fullfile( cd, 'data_parser' );
addpath( path_ );
clear path_;