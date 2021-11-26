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
ComoLake = struct( 'Lon', 9.38175, 'Lat', 45.853973); 
ComoLake.r = 44;
ComoLake.c = 39;

% process_data_root = fullfile( matlabdrive, 'lakeComoForecastData' );
% addpath( process_data_root );

std_aggregation = [caldays([1; 3; 7; 14; 21; 28; 42]); calmonths(1:7)'];

path_ = fullfile( cd, 'data_parser' );
addpath( path_ );
path_ = fullfile( cd, 'stats' );
addpath( path_ );
clear path_;