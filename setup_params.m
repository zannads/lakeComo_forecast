%ADD PATHS AND CONSTANTS

global raw_data_root;
raw_data_root = '/Users/denniszanutto/Documents/Data';
addpath( raw_data_root );

Fuentes = struct( 'Lon', 9.412760, 'Lat', 46.149950);
Fuentes.fname = 'Fuentes';
Fuentes.r = 45;
Fuentes.c = 33;
Olginate = struct( 'Lon', 9.41338, 'Lat', 45.8053);
Olginate.fname = 'Olginate';
Olginate.r = 45;
Olginate.c = 40;
LakeComo = struct( 'Lon', 9.38175, 'Lat', 45.853973);
LakeComo.fname = 'LakeComo';
LakeComo.r = 44;
LakeComo.c = 39;
Mandello = struct( 'Lon', 9.310840, 'Lat', 45.904705); 
Mandello.fname = 'Mandello';
Mandello.r = 43;
Mandello.c = 38;

% process_data_root = fullfile( matlabdrive, 'lakeComoForecastData' );
% addpath( process_data_root );

std_aggregation = [caldays([1, 3, 7:7:28])'; calmonths(1); caldays([42, 56])'; calmonths(2:7)'];

path_ = fullfile( cd, 'data_parser' );
addpath( path_ );
path_ = fullfile( cd, 'stats' );
addpath( path_ );
path_ = fullfile( cd, 'draws' );
addpath( path_ );
clear path_;

colors.det = [51, 51 255]/255; % special blue
colors.cic = [1.00 0.54 0.00];  % orange-
colors.ave = [0.47 0.25 0.80];  % purple
colors.con = [0, 51, 0;         % scale of greens
              0, 77, 0;
              0, 102, 0;
              0, 128, 0;
              0, 153, 0;
              0, 179, 0]/255;
colors.prob2det = [64, 0, 255;
                   255, 0, 255]/255;
colors.efsr = [0, 255, 0;         % scale of blues
              0, 255, 255;
              0, 0, 255;
              255, 153, 51]/255;
colors.efrf = [];
colors.lim = [1,0,0]; % red
 