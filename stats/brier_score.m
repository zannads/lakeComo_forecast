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
                    'Error. \nThe input must be defined in the same time period.' );
            end
            
            m = size( f, 3 );
            outputArg = brier_score.empty( m );
            
            for mdx = 1:m
                %% calculate
                % go along 3rd direction
                f_ = f(:,:, mdx);
                o_ = o(:,:, mdx);
                % remove nan
                f_( isnan(f_(:,1)), :) = [];
                o_( isnan(o_(:,1)), :) = [];
                
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
                outputArg.type = brier_score.type;
            end
        end
        
        function outputArg = type( varargin )
            %type is used for set or get how the boundaries are defined
            %during the year.
            %   There are 3 possible types of division of the year: -
            %   annual: just one separation for the whole year. - seasonal:
            %   one separation for each season. - monthly: one separation
            %   for each month.
            % See also brier_score.boundaries.
            
            %% parse input
            valid_types = {'annual', 'seasonal', 'monthly' };
            if nargin>0 & ~any( strcmp( varargin{1}, valid_types ) )
                error( 'BRIER:input', 'The inserted type is not valid.' );
            end
            
            % persistent allows to save the variable between calls, since
            % the method is static, there is just one istance of it always
            % existing, but not global.
            persistent type;
            if nargin
                type = varargin{1};
                brier_score.boundaries( [] ); % reset boundaries to avoid errors
            else
                if isempty(type)
                    error( 'BRIER:output', 'The type has not been inserted yet.' );
                end
            end
            
            outputArg = type;
        end
        
        function outputArg = boundaries( varargin )
            %boundaries set or get the boundaries that are used during the
            %year.
            %   The size for now is arbitrary. It should be one less than
            %   the number of classes.
            % See also brier_score.type.
            
            %%TODO check input( must be numeric
            
            persistent bound;
            if nargin
                bound = varargin{1};
            else
                if isempty(bound)
                    error( 'BRIER:output', 'The boundaries have not been inserted yet.' );
                end
            end
            
            outputArg = bound;
        end
        
        function tercile = extract_bounds(tt, quant)
            %extract_bounds Allows to extract the quantiles for a given
            %timetable of historical observations.
            
            %% input parser
            if ~istimetable( tt )
                error( 'BRIER:input', ...
                    'Error. \nThe input must be a Time Series object.' );
            end
            
            if isempty( quant )
                error( 'BRIER:input', ...
                    'Error. \nThe input is empty.' );
            elseif any(quant<=0 | quant >=1 )
                error( 'BRIER:input', ...
                    'Error. \nThe quantiles inserted are not valid.' );
            end
            
            q = size(quant, 2);
            st_year = min( tt.Time.Year );
            end_year = max( tt.Time.Year );
            
            if strcmp( brier_score.type, 'annual' )
                %% ANNUAL
                tercile(1, :) = quantile( reshape(tt.Variables, 1, []), quant );
                
            elseif strcmp( brier_score.type, 'seasonal' )
                %% SEASONAL
                % 4 seasons
                
                % dates that divide the seasons
                sd = [21, 3; 21, 6; 23, 9; 21, 12; 21, 3];
                for seas = 1:4
                    h = timetable; %empty
                    
                    if seas <4 %spring, summer and fall all fells during the year
                        for year= st_year:end_year
                            season = timerange( datetime( year, sd(seas, 2), sd(seas, 1) ), ... %start date
                                datetime( year, sd(seas+1, 2), sd(seas+1, 1) ) );     %end date
                            h = [ h; tt(season, :) ]; %#ok<*AGROW>
                        end
                    else    % winter falls between years.
                        for year= st_year-1:end_year
                            season = timerange( datetime( year, sd(seas, 2), sd(seas, 1) ), ... %start date
                                datetime( year+1, sd(seas+1, 2), sd(seas+1, 1) ) );     %end date
                            h = [ h; tt(season, :) ];
                        end
                    end
                    
                    if ~isempty(h)
                        tercile(seas, :) = quantile( reshape(h.Variables, 1, []), quant );
                    end
                end
                
            else
                %% MONTHLY
                for mon = 1:12
                    h = timetable;
                    
                    for year= st_year:end_year
                        month = timerange( datetime( year, mon, 1), ... %start date
                            datetime( year, mon, 1 )+calmonths(1) ) ;    %end date
                        h = [ h; tt(month, :) ];
                    end
                    
                    if ~isempty(h)
                        tercile(mon, :) = quantile( reshape(h.Variables, 1, []), quant );
                    end
                end
            end
        end
        
        function outputArg = parse( signal )
            %parse creates the array with the probabilities given the
            %timetable of the forecast or of the observation.
            % If a forecast with nE ensamble is passed as input the output
            % will be probabilties for each class. If a time history is
            % passed, it works anyway so that the time history is parsed
            % into an array for all the classes in which it is divided.
            
            %% parse input
            if ~istimetable( signal )
                error( 'BRIER:input', ...
                    'Error. \nThe input must be a timetable object.' );
            end
            
            [~, nE] = size( signal);
            %% get the boundaries
            % if something its not set it will throw an error.
            t = brier_score.boundaries;
            [m, q] = size( t);
            
            %% dec
            temp = signal.Variables;
            
            %if strcmp( brier_score.type, 'annual' )
            % ANNUAL
            % no change needed
            
            if strcmp( brier_score.type, 'seasonal' )
                %% seasonal
                temp_m = repmat(cell(1), 1, 1, 4);
                
                % reshape per season
                time_ = signal.Time;
                seas = 1; % before spring begin
                fy = signal.Time.Year(1); % first year
                sd = [21, 3; 21, 6; 23, 9; 21, 12; 21, 3]; % days that separate seasons
                while ~isempty( temp )
                    % get the array pos before the change of the season
                    per = time_ < datetime(fy, sd(seas, 2), sd(seas, 1));
                    
                    % append the element of that season to the relative
                    % season, I should use seas-1.
                    if seas ~= 1
                        temp_m{seas-1} = [temp_m{seas-1}; temp( per, : )];
                    else
                        % I can't index with 0, winter is 4
                        temp_m{4} = [temp_m{4}; temp( per, : )];
                    end
                    
                    % remove the used period
                    time_(per, :) = [];
                    temp( per, :) = [];
                    
                    % go to next season
                    if seas <4
                        seas = seas+1;
                    else
                        seas = 1;
                        % again to spring, change year
                        fy = fy +1;
                    end
                end
                
                
                % get longest
                max_l = 0;
                for seas = 1:4
                    max_l = max( max_l, size(temp_m{seas}, 1) );
                end
                
                % fill the nans and then concatenate
                for seas = 1:4
                    temp_m{seas}(end+1:max_l, :) = nan;
                end
                temp = cell2mat( temp_m );
                %{
                % extract the season where it starts.
                fd = signal.Time(1);
                fy = signal.Time.Year(1);
                if (fd >= datetime(fy , 3, 21) ) & (fd < datetime(fy, 6, 21) )
                    % spring
                    seas = 1;
                    daysToNext = days(datetime(fy, 6, 21)-fd);
                elseif (fd >= datetime(fy , 6, 21) ) & (fd < datetime(fy, 9, 23) )
                    % summer
                    seas = 2;
                    daysToNext = days(datetime(fy, 9, 23)-fd);
                elseif (fd >= datetime(fy , 9, 23) ) & (fd < datetime(fy, 12, 21) )
                    % fall
                    seas = 3;
                    daysToNext = days(datetime(fy, 12, 21)-fd);
                else
                    % winter
                    seas = 4;
                    daysToNext(1) = days(datetime(fy, 3, 21)-fd);
                    daysToNext(2) = days(datetime(fy+1, 3, 21)-fd);
                    daysToNext = daysToNext( daysToNext>0 );
                    daysToNext = min( daysToNext );
                end
                
                % now go on for all the days in the time series
                idx = 1;
                while idx <= height( signal )
                    outputArg(idx, 1) = sum(temp(idx, :) <= t(seas, 1))/nE;
                    outputArg(idx, 2) = sum( (temp(idx, :) > t(seas, 1)) & ...
                        (temp(idx, :) <= t(seas, 2)) , 2 )/nE;
                    outputArg(idx, 3) = sum(temp(idx, :) > t(seas, 2))/nE;
                    
                    idx = idx+1;
                    daysToNext = daysToNext -1;
                    if daysToNext==0
                        fd = signal.Time(idx);
                        fy = signal.Time.Year(idx);
                        if seas==1
                            seas = 2;
                            daysToNext = days(datetime(fy, 9, 23)-fd);
                        elseif seas==2
                            seas = 3;
                            daysToNext = days(datetime(fy, 12, 21)-fd);
                        elseif seas==3
                            seas = 4;
                            daysToNext = days(datetime(fy+1, 3, 21)-fd);
                        else
                            seas = 1;
                            daysToNext = days(datetime(fy, 6, 21)-fd);
                        end
                    end
                end
                %}
                
            elseif strcmp( brier_score.type, 'monthly' )
                %% monthly
                max_l = 0;
                temp_m = repmat(cell(1), 1, 1, 12);
                
                % reshape per month
                for mon = 1:12
                    temp_m{mon} = temp( signal.Time.Month == mon, : );
                    max_l = max( max_l, size(temp_m{mon}, 1) );
                end
                
                % fill the nans and then concatenate
                for mon = 1:12
                    temp_m{mon}(end+1:max_l, :) = nan;
                end
                temp = cell2mat( temp_m );
            end
            
            %% calculation
            outputArg = nan( size( temp, 1 ), q+1, m );
            
            for mdx = 1:m
                s = temp(:, :, mdx);
                sdx = ~isnan( s(:,1) );
                
                qdx = 1;
                outputArg(sdx, qdx, mdx) = sum( s(sdx, :) <= t(mdx, 1), 2)/nE;
                
                for qdx = 2:q
                    outputArg(sdx, qdx, mdx) = sum( (s(sdx, :) > t(mdx, qdx-1)) & (s(sdx, :) <= t(mdx, qdx)), 2)/nE;
                end
                
                qdx = q+1;
                outputArg(sdx, qdx, mdx) = sum(s(sdx, :) > t(mdx, q), 2)/nE;
            end
            
        end
        
        function [r, d, k] = decompose( forecast, observation )
            %decompose divides the forecast into the different occurencies
            %that are possible and store it in r. It is a limited set by
            %definition. It also saves how many of them there are in the
            %the whole set of the forecast. Moreover, it computes the
            %average of the observation for that occurency.
            
            if isempty( forecast ) | isempty( observation )
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
                outputArg.type = "";
            else
                outputArg.bs = [];
                outputArg.rel = [];
                outputArg.res = [];
                outputArg.unc = [];
                outputArg.type = "";
            end
        end
    end
end

