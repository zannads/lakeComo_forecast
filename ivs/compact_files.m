function data = compact_files( file_ )
    % merge the list of file into one single variable! 
    % main assumptions: 
    %   A1- all time series are equally long
    %   A2- the last name is for the output file 
    
    n_f = length( file_ );
    n_t = length( load( file_{end} , '-ascii' ) ); %A1
    
    data = nan( n_t, n_f );
    for idx = 1:n_f
        temp = load( file_{idx} , '-ascii' );
        data(:, idx) = temp(1:n_t);
    end
end