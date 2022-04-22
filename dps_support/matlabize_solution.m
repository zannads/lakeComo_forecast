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
    %           metrics:            Array with Hypervolume GenerationalDistance
    %                               InvertedGenerationalDistance Spacing
    %                               EpsilonIndicator MaximumParetoFrontError
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
    stF = ls( '~/Documents/Data/EMODPS_solutions/BOP/output/settings*' );
    outputArg.settings_file = stF(1:end-1); %remove the /n that is appended by ls
    clear stF
    
    % load reference set
    if forceReference || ~exist( fullfile( filePath, 'output', 'optComo_borg.reference' ), 'file' )
        system( ['~/Documents/LakeComo_EMODPS/MOEAFramework/borg_reference.sh ', filePath] )
    end
    outputArg.reference = load( fullfile( filePath, 'output', 'optComo_borg.reference' ), '-ascii' );
    
    % load metrics
    if forceMetric || ~exist( fullfile( filePath, 'output', 'optComo_borg.metrics' ), 'file' )
        system( ['~/Documents/LakeComo_EMODPS/MOEAFramework/run_final_metric.sh ', filePath] )
    end
    fid = fopen( fullfile( filePath, 'output', 'optComo_borg.metrics' ), 'r' );
    fgetl( fid ); % dump the first row with the names
    tline = fgetl( fid ); % get the values
    nline = str2double( split( tline, ' ', 2 ) ); % transfrom in double
    
    
    outputArg.metrics = nline;
    
    
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

