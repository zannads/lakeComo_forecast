function data = compact_files( file_ )
    % merge the list of file into one single variable! 
    % main assumptions: 
    %   A1- all time series are equally long
    %   A2- the last name is for the output file 
    global raw_data_root;
    
    n_f = length( file_ );
    n_t = length( load( fullfile( raw_data_root, 'candidate_variables', file_(1) ), '-ascii' ) ); %A1
    
    data = nan( n_t, n_f );
    for idx = 1:n_f
        data(:, idx) = load( fullfile( raw_data_root, 'candidate_variables', file_(idx) ), '-ascii' );
    end
end