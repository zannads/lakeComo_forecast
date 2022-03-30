classdef brier_score
    %brier_score Set of static methods to compute the Brier Score.
    %   The Brier score is a score for probabilistic forecasts. It is
    %   defined as in Brier 1950.
    %   Its decomposition follows Murphy 1973.
    %   BS = REL - RES + UNC
    %   REL is the reliability of the forecast.
    %   RES is the resolution of the forecast.
    %   UNC is a measure of the intrinsic noise of the observed system.
    methods (Static)
        function outputArg = calculate( f, o )
            %calculate Calculates the brier score.
            %   bs = brier_score.calculate( forecast, observation )
            %   calculates the BS for the forecast given the observation.
            %   [bs, rel, res, unc]= brier_score.calculate( forecast,
            %   observation ) calculates the BS and its decomposition.
            %   forecast and observation need to be synchornized timetable
            %   where forecast has an ensamble for each column.
            
            %% parse input
            % check they are the same lenght and the correct type.
            %TODO check is array
            
            if any(size(f) ~= size(o))
                error( 'BRIER:input', ...
                    'The input must be defined in the same time period.' );
            end
            if ~isnumeric(f) || ~isnumeric(o)
                error( 'BRIER:input', ...
                    'The input must be a numeric type.' );
            end
            
            % third dimension is the number of period in which the series is divided,
            % can be seasons or month or something else.
            m = size( f, 3 );
            % preallocate
            outputArg = brier_score.empty( m );
            
            for mdx = 1:m
                %% calculate
                % go along 3rd direction
                f_ = f(:,:, mdx);
                o_ = o(:,:, mdx);
                % remove nan
                f_( isnan(f_(:,1)), :) = [];
                o_( isnan(o_(:,1)), :) = [];
                
                if ~isempty(f_) & ~isempty(o_)
                    
                    n = size( f_, 1);    % n number of forecast issued /  lenght of the forecast period.
                    d_bar = sum( o_, 1 )/n; % average
                    
                    % following the paper from Murphy we see that the forecast can
                    % assume a discrete set of values.
                    % r is the collection of the different values.
                    % d is the average of the observations for the corresponding r.
                    % k is the number of times that value appeared  in the whole
                    % timehistory, sum k = 1.
                    [r, d, k] = brier_score.decompose( f_, o_ );
                    
                    % Brier score accordingly to Brier 1950.
                    bs = sum( (f_-o_).^2 , 'all')/n;
                    % Decomposition accordingly to Murhpy 1973.
                    rel = 1/n*k'*diag((r-d)*(r-d)');
                    res = 1/n*k'*diag((d-d_bar)*(d-d_bar)');
                    unc = d_bar*( ones(size(d_bar)) - d_bar)';
                    
                    outputArg.bs(mdx) = bs;
                    outputArg.rel(mdx) = rel;
                    outputArg.res(mdx) = res;
                    outputArg.unc(mdx) = unc;
                    
                else
                    outputArg.bs(mdx) = nan;
                    outputArg.rel(mdx) = nan;
                    outputArg.res(mdx) = nan;
                    outputArg.unc(mdx) = nan;
                end
            end
        end
        
        function code = validType( tp )
            %valideType is a function to check the validity of the passed quantile
            %division.
            %   There are 6 possible types of division of the year: -
            %   annual: just one separation for the whole year. 
            %   - seasonal: one separation for each season, following the natural definition. 
            %   - monthly: one separation for each month.
            %   - quarterly: one separation for each quarter of the year( MAM, JJA,
            %   SON, DJF )
            %   tp = validType( tp ) throws an error if the inserted modality is not
            %   valid.
            
            %% parse input
            valid_types = {'annual', 'seasonal', 'monthly', 'quarterly', 'weekly', 'daily' };
            if nargin<1 || ~any( strcmp( tp, valid_types ) )
                error( 'BRIER:input', 'The inserted type is not valid.' );
            end
            
            code = find( strcmp( tp, valid_types )  );
        end
        
        function bnd = extract_bounds(tt, quant, type, varargin)
            %extract_bounds Allows to extract the quantiles for a given
            %timetable of historical observations.
            
            %% input parser
            if istimetable( tt ) 
                ts = tt.Time;
                tt = tt.Variables;
            elseif isnumeric(tt) && nargin > 3  && isdatetime(varargin{1}) && size(tt,1) == size(varargin{1}, 1)
                ts = varargin{1};
                %tt = tt
            else
                error( 'BRIER:input', ...
                    'The input must be a Timetable object or the 1st input a numeric matrix and the 4th a datetime array.' );
            end
            
           if any(quant<0 | quant >1 )
                error( 'BRIER:input', ...
                    'The quantiles inserted are not valid, it must be a value between 0 and 1.' );
           end
           
           brier_score.validType( type );
           
            %% extract bounds
            % get a logic array of size [t, m] that for each coloumn extracts the
            % datetime in the array that are for that division.
            selectT = brier_score.timeSplitter( ts, type ); 
            
            q = size( quant , 2);
            m = size( selectT,2);
            
            bnd = nan(m, q);
            
            for mdx = 1:m
                % extract the variable for which I need the quantile
                sig = tt(selectT(:,mdx),:);
                
                bnd(mdx, :) =  quantile( sig(:)' , quant );
            end
        end
        
        function msk = timeSplitter( ts, type )
            %timeSplitter generates a logic array of size [t, k] where each column says
            %which element need to be selected to split the time array with the selected splitting modality.
            %   mask = brier_score.timeSplitter( time, modality )
            %   returns a logic matrix of size [t, k] where t is the dimension of the
            %   datetime array and k is set accordingly to the splitting criterion:
            %   'annual'    : k=1,
            %   'seasonal'  : k=4,
            %   'monthly'   : k=12,
            %   'quarterly' : k=4,
            %   'weekly'    : k=52,
            %   'daily'     : k=365.
          
            %% input check
            if ~isdatetime( ts )
               error( 'BRIER:input', ...
                   'The input must be a Timetable object or the 1st input a numeric matrix and the 4th a datetime array.' );
            end
            
            code = brier_score.validType( type );
            
            t = size(ts, 1);
            %% switch
            switch code
                case 1
                    % ANNUAL
                    msk = true( t, 1);
                    
                case 2
                    % SEASONAL
                    % 4 seasons
                    msk = false(t, 4);
                    
                    % dates that divide the seasons
                    sd = [21, 3; 21, 6; 23, 9; 21, 12; 21, 3];
                    st_year  = min( ts.Year );
                    end_year = max( ts.Year );
                    for seas = 1:4
                        
                        % datetime array of size [2, numberOfYears]
                        if seas <4
                            season = [datetime( st_year:end_year, sd(seas,2), sd(seas,1) );
                                datetime( st_year:end_year, sd(seas+1,2), sd(seas+1,1) )];
                        else
                            season = [datetime( st_year-1:end_year, sd(seas,2), sd(seas,1) );
                                datetime( st_year:end_year+1, sd(seas+1,2), sd(seas+1,1) )];
                        end
                        
                        msk(:, seas) = any(ts>= season(1,:) & ts <season(2,:), 2);
                    end
                    
                case 3
                    % MONTHLY
                    msk = ts.Month == 1:12;
                    
                case 4
                    % QUARTERLY
                    msk = false(t, 4);
                    for qrt = 1:4
                        msk(:,qrt) = any(ts.Month == mod((qrt-1)*3+[11,12,13],12)+1, 2);
                    end
               % case 5 weekly 
               % case 6 daily
                otherwise 
                    fprintf( '%s not implemented yet\m', type );     
            end
        end
        
        function outputArg = parse( tt, bounds, type, keepLinear )
            %parse creates the array with the probabilities given the
            %timetable of the forecast or of the observation.
            % If a forecast with nE ensamble is passed as input the output
            % will be probabilties for each class. If a time history is
            % passed, it works anyway so that the time history is parsed
            % into an array for all the classes in which it is divided.
            
            %% parse input
            if ~istimetable( tt )
                error( 'BRIER:input', ...
                    'The first input must be a timetable object.' );
            else
                ts = tt.Time;
                tt = tt.Variables;
            end
            
            if ~isnumeric( bounds )
                error( 'BRIER:input', ...
                    'The second input must be a numeric matrix.' );
            end
            
            %% start the parsing
            [nT, nE] = size( tt );
            [m, q]   = size( bounds );
            %checks also type
            msk = brier_score.timeSplitter( ts, type );
            if size(msk, 2) ~= m
                error( 'BRIER:input', ...
                    'Type and bounds dimension are not matching.' );
            end
            
            % parse last input linear
            % target*Array are logic or numeric array to select the indexes of
            % outputArg to save the information.
            % target1dArray matrxi [nT, m] with logic array, each column selects the
            % targets of where saving the point in time.
            % target3dArray is a number containg the 3d dimension, aka the page where
            % to save. If is linear we are keeping time dimension intact, otherwise if
            % we are folding we need to select the correct page.
            if nargin > 3 && strcmp( keepLinear, 'linear' ) 
                target1dArray = msk;
                target3dArray = ones(1, m); 
                outputArg = nan(nT, q+1, 1);
            elseif nargin == 3 || nargin > 3 && strcmp( keepLinear, 'fold' )
                target1dArray = (1:nT)'<=sum(msk, 1);
                target3dArray = 1:m;
                nM = max( sum(msk, 1) );    % the maximum amount of the day extracted in the same category
                outputArg = nan(nM, q+1, m);
            else
                error( 'BRIER:input', ...
                    'The last input must be one of the following strings: linear or fold.' );
            end
            
            target2dArray = 1:q+1;
            th = [-inf(m,1), bounds ,inf(m,1)]; % size [m, q+2]
            %% calculation
            for mdx = 1:m
                
                target1d = target1dArray(:,mdx); % array from 1 to last element of the column, (nT if is linear, n for that type if fold)
                target3d = target3dArray(  mdx);
                targetEx = msk(:,          mdx);
                
                for target2d = target2dArray
                    outputArg(target1d, target2d, target3d) = sum( ...
                        (tt(targetEx, :) > th(mdx, target2d)) & (tt(targetEx, :) <= th(mdx, target2d+1))...
                        , 2)/nE;
                end
            end
           
        end
        
        function [r, d, k] = decompose( forecast, observation )
            %decompose divides the forecast into the different occurencies
            %that are possible and store it in r. It is a limited set by
            %definition. It also saves how many of them there are in the
            %the whole set of the forecast. Moreover, it computes d, the
            %average of the observation for that occurency.
            
            if isempty( forecast ) || isempty( observation )
                % We reached the end of the recursion.
                r = [];
                d = [];
                k = [];
                return;
            elseif size( forecast, 1) == size( observation, 1)
                % just a fast check on the dimension. It should be checked
                % before calling this function.
                
                % Take the first element.
                r = forecast(1, :);
                
                % find which are equal to the first
                isthesame = all( forecast == r, 2);
                
                %for_extr = forecast( isthesame, :);
                obs_extr = observation( isthesame, :);
                
                % count how many times this occurency appears in the whole
                % set.
                k = size( obs_extr, 1);
                %calculate the average of the observations.
                d = sum( obs_extr, 1)/k;
                
                % recursivelly call for the remaining part
                [r1, d1, k1] = brier_score.decompose( forecast(~isthesame,:), observation(~isthesame,:) );
                
                % stack the output.
                r = [r;r1];
                d = [d;d1];
                k = [k;k1];
                return;
                
            else
                error( 'BRIER:input', ...
                    'The size of the vectors are not the same, it is not possible to continue the recursion.' );
            end
        end
        
        function outputArg = empty( m )
            if nargin
                outputArg.bs = nan(1,m);
                outputArg.rel = nan(1,m);
                outputArg.res = nan(1,m);
                outputArg.unc = nan(1,m);
            else
                outputArg.bs = [];
                outputArg.rel = [];
                outputArg.res = [];
                outputArg.unc = [];
            end
        end
    end
end

