%ADD PATHS

raw_data_root = '/Users/denniszanutto/OneDrive - Politecnico di Milano/Master Thesis DZ/Data/Short_term_forecast/'; 
addpath( raw_data_root );

process_data_root = fullfile( matlabdrive, 'lakeComoForecastData' );
addpath( process_data_root );

path_ = fullfile( cd, 'data_parser' );
addpath( path_ );
clear path_;