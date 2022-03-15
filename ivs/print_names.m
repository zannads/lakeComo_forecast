function selected = print_names( c_v, X)
    % c_v name of the candidate variables
    % X selected candidate variables, 0 means no selection
    % selected string matrix of the same dimension of X, where the neame is
    % inserted instead of the number
    
    selected = cell( size(X) );
    selected(X>0) = c_v(X(X>0));
end