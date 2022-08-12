function p2d = order2plot(p2d)
    %ORDER2PLOT given a 2 dimensional array compute some kind of pareto front
    [qq, ord] = sort( p2d(:,1) );
    p2d = [ qq, p2d(ord,2) ]; % reorder along the first dim
    
    idx = 2;
    while idx <= length(p2d)
        if p2d(idx,2) >p2d(idx-1,2)
            p2d(idx,:) = []; % you automatically go one ahead by removing
        else
            idx = idx+1;
        end
    end
end

