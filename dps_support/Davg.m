function value = Davg(set, target)
    %Davg Returns the average distance of the points in the set from the target
    %point.
    %       distance = Davg(set, target) returns the average distance of
    %       the points in the matrix set from the target point.
    
    if ~isnumeric(target) || ~isvector(target)
        error( 'Davg:input', ...
                    'The target must be a numeric vector.' ); 
    end
    target = target(:)'; % transform in horizontal vector
    
    if ~isnumeric(set) || ~ismatrix(set)
        error( 'Davg:input', ...
                    'The set must be a numeric 2D matrix.' ); 
    end
    
    if size( set, 1 ) == length(target) 
        set = set';
    elseif size( set, 2 ) == length(target) 
        %nothing to be done
    else
        error( 'Davg:input', ...
                    'Dimensions are not matching.' ); 
    end
    
    value = mean( vecnorm( set-target, 2, 2) );
    
end