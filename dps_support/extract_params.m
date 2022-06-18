function pTheta = extract_params(fullsol,ref_idx)
    %EXTRACT_PARAMS returns the params of the seed and of the solution of that
    %seed (the line in the .out file basically) associated to the requested point of
    %the reference set of that problem.
    %   pTheta = extract_params( solution, referenceN ) 
    
    for idx = 1:length(fullsol.seed)
        reflink = cat(2, fullsol.seed(idx).solution.ref);
        
        if any( reflink == ref_idx )
            
            sol_idx = find( reflink == ref_idx, 1, 'first' );
            seed_idx = idx; 
            pTheta = fullsol.seed(seed_idx).solution(sol_idx).params;
            return;
        end
    end
end

