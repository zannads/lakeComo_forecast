function outputArg = matlabize_solution( filePath , forceReference, forceMetric)
    %matlabize_solution Transforms the result of a EMODPS optimization (with my
    %definition) into a MATLAB struct
    %   BOP_sol = matlabize_solution( '../BOP' )
    %       
    %           generates a struct BOP_sol with the fields:
    %
    %           settings_file:      problem file settings path and name 
    %           reference:          matrix NxNobj with the reference set
    %                               extracted from all the seeds
    %           metrics:            struct with 
    %                       Hypervolume
    %                       GenerationalDistance
    %                       InvertedGenerationalDistance 
    %                       Spacing
    %                       EpsilonIndicator 
    %                       MaximumParetoFrontError
    %                       Dmin 
    %                       Davg
    %           seed:               array of sruct for each seed in the
    %                               simulation, composed of:
    %
    %               solution:       array of struct for each gene obtain from
    %                               the simulation, each one divided in:
    %
    %                       params: array with gene values
    %                       J:      performance of that gene
    %                       ref:    scalar value that link the solution to
    %                               the reference set of the optimization on
    %                               which is in. NaN if it isn't in the
    %                               reference set.
    
    if nargin==1
        forceReference = false;
        forceMetric    = false;
    else
        narginchk( 3,3 );
    end
    
    % load settings_file or better is to save name to create the model after
    stF = ls( [filePath, '/output/settings*'] );
    outputArg.settings_file = stF(1:end-1); %remove the /n that is appended by ls
    clear stF
    
    % load reference set
    if forceReference || ~exist( fullfile( filePath, 'output', 'optComo_borg.reference' ), 'file' )
        here = cd();
        cd('~/Documents/LakeComo_EMODPS/MOEAFramework');
        system( ['./borg_reference.sh ', filePath] )
        cd(here);
    end
    outputArg.reference = load( fullfile( filePath, 'output', 'optComo_borg.reference' ), '-ascii' );
    
    % load metrics
    target = [4.45, 1.082067011416135e+03, 9.85]; 
    %normalization
    normOBJ = [10, 500, 40];
    
    if forceMetric || ~exist( fullfile( filePath, 'output', 'optComo_borg.metrics' ), 'file' )
        here = cd();
        cd('~/Documents/LakeComo_EMODPS/MOEAFramework');
        system( ['./run_final_metric.sh ', filePath] )
        cd(here)
    end
    fid = fopen( fullfile( filePath, 'output', 'optComo_borg.metrics' ), 'r' );
    fgetl( fid ); % dump the first row with the names
    tline = fgetl( fid ); % get the values
    nline = str2double( split( tline, ' ', 2 ) ); % transfrom in double
    fclose(fid);
    
    outputArg.metrics.Hypervolume = nline(1);
    outputArg.metrics.GenerationalDistance = nline(2);
    outputArg.metrics.InvertedGenerationalDistance = nline(3);
    outputArg.metrics.Spacing = nline(4);
    outputArg.metrics.EpsilonIndicator = nline(5);
    outputArg.metrics.MaximumParetoFrontError = nline(6);
    outputArg.metrics.Dmin = Dmin( outputArg.reference./normOBJ, target./normOBJ );
    outputArg.metrics.Davg = Davg( outputArg.reference./normOBJ, target./normOBJ );
    
    
    % load seeds
    seedsInfo = dir( fullfile( filePath, 'output', 'optComo_borg_*.out' ) );
    nS = length(seedsInfo); % discover how many
    % allocate space
    outputArg.seed(nS).solution = [];
    for idx = 1:nS
        fid = fopen( fullfile(seedsInfo(idx).folder, seedsInfo(idx).name ), 'r' );
        
        ss = 1;
        tline = fgetl( fid );
        
        while tline ~= -1
            % only for numeric rows
            if tline(1) ~= '#'
                nline = str2double( split( tline, ' ', 2 ) ); % transfrom in double
                
                outputArg.seed(idx).solution(ss).params = nline(1:end-3);
                outputArg.seed(idx).solution(ss).J      = nline(end-2:end);
                
                %link to outputArg.reference
                diff_sol = outputArg.reference - nline(end-2:end);
                diff_sol = vecnorm( diff_sol' );
                
                % if it is close to at least one solution
                if any( diff_sol < 10^-6 )
                    [~, jdx] = min( diff_sol );
                    outputArg.seed(idx).solution(ss).ref = jdx;
                else
                    outputArg.seed(idx).solution(ss).ref = nan;
                end
                
                % next sol
                ss = ss +1;
            end
            tline = fgetl( fid );
        end
        fclose( fid );
    end
end

