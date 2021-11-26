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
        function outputArg = calculate( forecast, observation )
            %calculate Calculates the brier score.
            %   bs = brier_score.calculate( forecast, observation )
            %   calculates the BS for the forecast given the observation.
            %   [bs, rel, res, unc]= brier_score.calculate( forecast,
            %   observation ) calculates the BS and its decomposition.
            %   forecast and observation need to be synchornized timetable
            %   where forecast has an ensamble for each column.
            
            %% parse input
            % check they are the same lenght and the correct type.
            if ~istimetable( forecast )
                error( 'BRIER:input', ...
                    'Error. \nThe input must be a timetable object.' );
            end
            if ~ istimetable( observation )
                error( 'BRIER:input', ...
                    'Error. \nThe input must be a timetable object.' );
            end
            if ~isequal( forecast.Time, observation.Time )
                error( 'BRIER:input', ...
                    'Error. \nThe input must be defined in the same time period.' );
            end
            
            %% Generate vectors
            % define the o and f vectors accordingly to the terciles.
            % o is a logic array where 1 is when the observation lies in
            % the class
            o = brier_score.parse( observation );
            % gen prob 
            % f is an array with the probabilty of falling in each class.
            % The probability is defined as the unifrom distirbution: the
            % number of ensamble falling in the class divided by the number
            % of the ensambles.
            f = brier_score.parse( forecast );
            
            %% calculate
            n = size( f, 1);    % n number of forecast issued /  lenght of the forecast period.
            d_bar = sum( o, 1 )/n; % average 
            
            % following the paper from Murphy we see that the forecast can
            % assume a discrete set of values. 
            % r is the collection of the different values.
            % d is the average of the observations for the corresponding r.
            % k is the number of times that value appeared  in the whole
            % timehistory, sum k = 1.
            [r, d, k] = brier_score.decompose( f, o );
            
            % Brier score accordingly to Brier 1950.
            bs = sum( (f-o).^2 , 'all')/n;
            % Decomposition accordingly to Murhpy 1973.
            rel = 1/n*k'*diag((r-d)*(r-d)');
            res = 1/n*k'*diag((d-d_bar)*(d-d_bar)');
            unc = d_bar*( ones(size(d_bar)) - d_bar)';
            
            outputArg.bs = bs;
            outputArg.rel = rel;
            outputArg.res = res;
            outputArg.unc = unc;
            outputArg.type = brier_score.type;
        end
        
        function outputArg = type( varargin )
            %type is used for set or get how the boundaries are defined
            %during the year.
            %   There are 4 possible types of division of the year: -
            %   annual: just one separation for the whole year. - seasonal:
            %   one separation for each season. - monthly: one separation
            %   for each month. - daily: one separation for each day.
            % See also brier_score.boundaries.
            
            %% parse input 
            valid_types = {'annual', 'seasonal', 'monthly', 'daily' };
            if nargin>0 & ~any( strcmp( varargin{1}, valid_types ) )
                error( 'BRIER:input', 'The inserted type is not valid.' );
            end
            
            % persistent allows to save the variable between calls, since
            % the method is static, there is just one istance of it always
            % existing, but not global.
            persistent type; 
            if nargin
                type = varargin{1};
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
            
            %%TODO check input
            
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
        
        function tercile = extract_tercile(historical, varargin)
            %extract_tercile Allows to extract the terciles for a given
            %timetable of historical observations. 
            %   For all the possible types the terciles are extracted using
            %   the uniform distribution.
            %   TODO: NORMAL DISTRIBUTION, DIFFERENT NUMBER OF CLASSES.
            
            %% input parser
            if ~istimetable( historical )
                error( 'BRIER:input', ...
                    'Error. \nThe input must be a Time Series object.' );
            end
            
            tercile = struct( 'annual', nan(1,2), 'seasonal', nan(4,2),...
                'monthly', nan(12,2), 'daily', nan(365,2) );
            
            %% ANNUAL
            h = reshape( historical.(1),  1, [] );
            h = sort( h );
            m = mod( length(h), 3);
            idx = floor( length(h)/3 );
            
            % the boundary lies between two istances, I add the mean
            % between them to extract it.
            if m == 1
                h = [h(1, 1:idx), mean(h(1, idx:idx+1)), ...
                    h( 1, (idx+1):(2*idx) ), mean( h( 1, (2*idx):(2*idx+1))),   h( 1, (2*idx+1):end ) ];
                idx = floor( length(h)/3 );
            elseif m == 2
                h = [h(1, 1:idx), mean(h(1, idx:idx+1)), h( 1, idx+1:end ) ];
                idx = floor( length(h)/3 );
            end
            
            tercile.annual(1,1) = h(1, idx);
            tercile.annual(1,2) = h(1, 2*idx);
            %% SEASONAL
            % 4 seasons
            st_year = min( historical.Time.Year );
            end_year = max( historical.Time.Year );
            
            % dates that divide the seasons
            sd = [21, 3; 21, 6; 23, 9; 21, 12; 21, 3]; 
            for seas = 1:4
                h = timetable; %empty
                
                if seas <4 %spring, summer and fall all falls during the year
                    for year= st_year:end_year
                        season = timerange( datetime( year, sd(seas, 2), sd(seas, 1) ), ... %start date
                            datetime( year, sd(seas+1, 2), sd(seas+1, 1) ) );     %end date
                        h = [ h; historical(season, :) ]; %#ok<*AGROW>
                    end
                else    % winter falls between years.
                    for year= st_year-1:end_year
                        season = timerange( datetime( year, sd(seas, 2), sd(seas, 1) ), ... %start date
                            datetime( year+1, sd(seas+1, 2), sd(seas+1, 1) ) );     %end date
                        h = [ h; historical(season, :) ];
                    end
                end
                
                if ~isempty(h)
                    
                    h = reshape( h.(1),  1, [] );
                    h = sort( h );
                    m = mod( length(h), 3);
                    idx = floor( length(h)/3 );
                    
                    if m == 1
                        h = [h(1, 1:idx), mean(h(1, idx:idx+1)), ...
                            h( 1, (idx+1):(2*idx) ), mean( h( 1, (2*idx):(2*idx+1))),   h( 1, (2*idx+1):end ) ];
                        idx = floor( length(h)/3 );
                    elseif m == 2
                        h = [h(1, 1:idx), mean(h(1, idx:idx+1)), h( 1, idx+1:end ) ];
                        idx = floor( length(h)/3 );
                    end
                    
                    tercile.seasonal(seas,1) = h(1, idx);
                    tercile.seasonal(seas,2) = h(1, 2*idx);
                end
            end
            
            
            %% MONTHLY
            for mon = 1:12
                h = timetable;
                
                for year= st_year:end_year
                    month = timerange( datetime( year, mon, 1), ... %start date
                        datetime( year, mon, 1 )+calmonths(1) ) ;    %end date
                    h = [ h; historical(month, :) ];
                end
                
                
                if ~isempty(h)
                    
                    h = reshape( h.(1),  1, [] );
                    h = sort( h );
                    m = mod( length(h), 3);
                    idx = floor( length(h)/3 );
                    
                    if m == 1
                        h = [h(1, 1:idx), mean(h(1, idx:idx+1)), ...
                            h( 1, (idx+1):(2*idx) ), mean( h( 1, (2*idx):(2*idx+1))),   h( 1, (2*idx+1):end ) ];
                        idx = floor( length(h)/3 );
                    elseif m == 2
                        h = [h(1, 1:idx), mean(h(1, idx:idx+1)), h( 1, idx+1:end ) ];
                        idx = floor( length(h)/3 );
                    end
                    
                    tercile.monthly(mon,1) = h(1, idx);
                    tercile.monthly(mon,2) = h(1, 2*idx);
                end
            end
            
            %% DAILY
            for day = 1:365
                h = timetable;
                
                for year= st_year:end_year
                    dayR = timerange( datetime( year, 1, 1)+caldays(day-1), ... %start date
                        datetime( year, 1, 1 )+caldays(day) );     %end date
                    h = [ h; historical(dayR, :) ];
                end
                
                if ~isempty(h)
                    
                    h = reshape( h.(1),  1, [] );
                    h = sort( h );
                    m = mod( length(h), 3);
                    idx = floor( length(h)/3 );
                    
                    if m == 1
                        h = [h(1, 1:idx), mean(h(1, idx:idx+1)), ...
                            h( 1, (idx+1):(2*idx) ), mean( h( 1, (2*idx):(2*idx+1))),   h( 1, (2*idx+1):end ) ];
                        idx = floor( length(h)/3 );
                    elseif m == 2
                        h = [h(1, 1:idx), mean(h(1, idx:idx+1)), h( 1, idx+1:end ) ];
                        idx = floor( length(h)/3 );
                    end
                    
                    tercile.daily(day,1) = h(1, idx);
                    tercile.daily(day,2) = h(1, 2*idx);
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
            
            nE = size( signal, 2);
            %% get the boundaries
            % if something its not set it will throw an error.
            t = brier_score.boundaries;
            t = t.(brier_score.type);
            
            %% dec
            if strcmp( brier_score.type, 'annual' )
                %% ANNUAL
                yea = 1;
                temp = table2array( timetable2table( signal, 'ConvertRowTimes', false ) );
                
                outputArg(:, 1) = sum(temp <= t(yea, 1), 2)/nE;
                outputArg(:, 2) = sum((temp > t(yea, 1)) & (temp <= t(yea, 2)), 2)/nE;
                outputArg(:, 3) = sum(temp > t(yea, 2), 2)/nE;
                
                
            elseif strcmp( brier_score.type, 'seasonal' )
                %% seasonal
                outputArg = zeros( length( signal.Time ), size( t, 2)+1 );
                temp = table2array( timetable2table( signal, 'ConvertRowTimes', false ) );
                
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
                
                
            elseif strcmp( brier_score.type, 'monthly' )
                %% monthly
                outputArg = zeros( length( signal.Time ), size( t, 2)+1 );
                temp = table2array( timetable2table( signal, 'ConvertRowTimes', false ) );
                
                for idx = 1:length( signal.Time )
                    mon = signal.Time.Month(idx);
                    
                    outputArg(idx, 1) = sum(temp(idx, :) <= t(mon, 1))/nE;
                    outputArg(idx, 2) = sum( (temp(idx, :) > t(mon, 1)) & ...
                        (temp(idx, :) <= t(mon, 2)) , 2 )/nE;
                    outputArg(idx, 3) = sum(temp(idx, :) > t(mon, 2))/nE;
                end
                
            else
                %%   daily
                outputArg = zeros( length( signal.Time ), size( t, 2)+1 );
                temp = table2array( timetable2table( signal, 'ConvertRowTimes', false ) );
                
                leapDay = 0;
                for idx = 1:length( signal.Time )
                    yea = signal.Time.Year(idx);
                    d_from_start = signal.Time(idx)-datetime( yea, 1, 1);
                    d = days( d_from_start )+1;
                    
                    % remove leap day and eventually do -1
                    if leapDay==0 & mod(yea, 4) == 0 & signal.Time.Month(idx)==2 & signal.Time.Day(idx) == 29
                        leapDay = 1;
                        count = 307; % there are 306 days between 28th feb to 31st dec, one more for the leap day
                    end
                    
                    if leapDay==1
                        if count==0
                            % the year has finished
                            leapDay = 0;
                        end
                        count = count -1;
                    end
                    
                    outputArg(idx, 1) = sum(temp(idx, :) <= t(d-leapDay, 1))/nE;
                    outputArg(idx, 2) = sum( (temp(idx, :) > t(d-leapDay, 1)) & ...
                        (temp(idx, :) <= t(d-leapDay, 2)) , 2 )/nE;
                    outputArg(idx, 3) = sum(temp(idx, :) > t(d-leapDay, 2))/nE;
                end
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
        
    end
end

