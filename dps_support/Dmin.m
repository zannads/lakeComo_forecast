function [value, idx] = Dmin(set, target)
    %Dmin Returns the minimum distance of the points in the set from the target
    %point.
    %       [distance, idx] = Dmin(set, target) returns the minimum distance of
    %       the points in the matrix set from the target point and the index of
    %       the matrix.
    
    if ~isnumeric(target) || ~isvector(target)
        error( 'Dmin:input', ...
                    'The target must be a numeric vector.' ); 
    end
    target = target(:)'; % transform in horizontal vector
    
    if ~isnumeric(set) || ~ismatrix(set)
        error( 'Dmin:input', ...
                    'The set must be a numeric 2D matrix.' ); 
    end
    
    if size( set, 1 ) == length(target) 
        set = set';
    elseif size( set, 2 ) == length(target) 
        %nothing to be done
    else
        error( 'Dmin:input', ...
                    'Dimensions are not matching.' ); 
    end
    
    [value, idx] = min( vecnorm( set-target, 2, 2) );
    
end

