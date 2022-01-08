%ADD PATHS AND CONSTANTS

global raw_data_root;
raw_data_root = '/Users/denniszanutto/Documents/Data';
addpath( raw_data_root );

Fuentes = struct( 'Lon', 9.412760, 'Lat', 46.149950);
Fuentes.fname = "Fuentes";
Fuentes.r = 45;
Fuentes.c = 33;
Olginate = struct( 'Lon', 9.41338, 'Lat', 45.8053);
Olginate.fname = "Olginate";
Olginate.r = 45;
Olginate.c = 40;
LakeComo = struct( 'Lon', 9.38175, 'Lat', 45.853973);
LakeComo.fname = "LakeComo";
LakeComo.r = 44;
LakeComo.c = 39;
Mandello = struct( 'Lon', 9.310840, 'Lat', 45.904705); 
Mandello.fname = "Mandello";
Mandello.r = 43;
Mandello.c = 38;
locations = [Fuentes, Mandello, LakeComo, Olginate];

std_aggregation = [caldays([1, 3, 7:7:28])'; calmonths(1); caldays([42, 56])'; calmonths(2:7)'];

DT_S = datetime(1999, 1, 1);
DT_E = datetime(2018, 12, 31);

path_ = fullfile( cd, 'data_parser' );
addpath( path_ );
path_ = fullfile( cd, 'stats' );
addpath( path_ );
path_ = fullfile( cd, 'draws' );
addpath( path_ );
clear path_;