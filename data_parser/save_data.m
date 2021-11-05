%save_data

add_paths

path_ = fullfile( matlabdrive, 'lakeComoForecastData', 'deterministic_data.mat' );
save( path_, 'historical', 'detForecast' );