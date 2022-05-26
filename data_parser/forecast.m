classdef forecast
    %FORECAST class that defines the forecasts and the method useful for
    %them.
    
    properties
        data;       % N-D double array.
        time;       % Array of datetime objects.
        leadTime;   % Maximum leadTime available.
        ensembleN;  % Number of the ensembles.
        location;   % Where this forecast has been issued.
        benchmark;  % logical value to be set if forecast is generated from historical data.
        name;       % name assigned to the forecast;
        description;% long description of the forecast if necessary.
    end
    
    methods
        function obj = forecast( time, data, varargin)
            %FORECAST Construct an instance of this class
            %   f = forecast( data, timearray ) construct an istance of
            %   this class. It is necessary that the time array is as loing
            %   as the first dimension of the data array.
            if nargin == 0
                % empty constructor
                return;
            end
            
            if ~isdatetime( time )
                error( 'Forecast:wrongInput', ...
                    'The first input must be a datetime object.' );
            end
            if ~isnumeric(data) || size( data, 1) ~= length(time)
                error( 'Forecast:wrongInput', ...
                    'The second input must be a numeric array with the first dimension matching the length of the time array.' );
            end
            obj.time = time;
            obj.data = data;
            
            defaultLT = size( data, 2);
            defaultEN = size( data, 3);
            defaultBN = false;
            defaultName = "forecast";
            defaultLoc = [];
            
            validLT = @(x) isscalar(x) && ( isnan(x) || isinf(x) || isnumeric(x) );
            validEN = @(x) isscalar(x) && ( isinf(x) || isnumeric(x) );
            validBN = @(x) isscalar(x) && islogical(x);
            validNA = @(x) isscalar(x) && isstring(x);
            validLo = @(x) true;
            
            p = inputParser;
            addParameter( p, 'LeadTime',        defaultLT,  validLT );
            addParameter( p, 'EnsembleNumber',  defaultEN,  validEN );
            addParameter( p, 'Benchmark',       defaultBN,  validBN );
            addParameter( p, 'Name',            defaultName,validNA );
            addParameter( p, 'Location',        defaultLoc, validLo );
            
            parse( p, varargin{:} );
            
            obj.leadTime    = p.Results.LeadTime;
            obj.ensembleN   = p.Results.EnsembleNumber;
            obj.benchmark   = p.Results.Benchmark;
            obj.name        = p.Results.Name;
            obj.location    = p.Results.Location;
        end
        
        function outputArg = getTimeSeries( obj, aggTime, leadTime, fill )
            % getTimeSeries ts = getTimeSeries( forecast, aggTime, leadTime ) creates a
            % timetable in the period of the forecast by aggregating using aggTime,
            % shifting ahead of the value inside the leadTime variable.
            %       
            %       getTimeSeries ts = getTimeSeries( forecast, aggTime, leadTime,
            %       fill) creates a timetable in the period of each forecast by
            %       aggregating using aggTime, shifting ahead of the value inside the
            %       leadTime variable. The fill flag checks if the forecast is at daily
            %       step, if it's not and the flag is true it generates a time series
            %       on a daily step.
            
            %% input check
            if nargin < 4 
                fill = false;
            end
            if ~islogical(fill) 
                error( 'Forecast:wrongInput', ...
                    'The fill flag must be a logical value.' );
            end
            if ~iscalendarduration(aggTime) && ~isnumeric(aggTime)
                error( 'Forecast:wrongInput', ...
                    'The aggregation time (second input) must be a calendar duration object value or a numeric.' );
            end
            if ~isnumeric(leadTime)
                error( 'Forecast:wrongInput', ...
                    'The lead time (third input) must be a numeric value.' );
            end
            if ~isscalar(aggTime) || ~isscalar(leadTime) || ~isscalar(fill)
                warning( 'The additional input must be scalar values. Only first element of the array is used' );
                aggTime = aggTime(1);
                leadTime = leadTime(1);
                fill = fill(1);
            end
                
            %% start working

            % creates a timetable for each forecast
            tt = cell(1, length(obj) );
            for idx = 1:length(obj)
                %%calculations
                if isinf( obj(idx).leadTime )
                    % the same value is for all lead times, i.e. I only need to move the dates.
                    % it's given for granted that the time series is already on a daily step.
                    
                    processedValues = obj(idx).data;
                    processedTime = obj(idx).time+leadTime;
                elseif isnan( obj(idx).leadTime )
                    % the value is perfectly known.. no lead time but
                    % aggregation is needed
                    % anyway it can still be a probabilistic desc or with
                    % ensembles or deterministic with only one
                    processedTime = obj(idx).time;
                    
                    if isinf( obj(idx).ensembleN )
                        % if it is probabilistic the variance is aggregated on a different way
                        processedValues(:,1) = aggregate_historical( obj(idx).time, obj(idx).data(:,1,1), aggTime );
                        processedValues(:,2) = aggregate_var( obj(idx), aggTime );
                    else
                        % if it is an ensemble of perfect knwon values I can simply aggregate
                        processedValues = aggregate_historical( obj(idx).time, obj(idx).data(:,1,:), aggTime );
                    end
                else
                    % obj.leadTime is a finite number
                    
                    if isinf( obj(idx).ensembleN )
                        %not implemented
                    else
                        % probabilistic with ensemble or deterministic
                        [processedValues, processedTime] = aggregate_unknown( obj(idx), aggTime, leadTime, fill );
                    end
                end
                
                % insert the names
                if obj(idx).ensembleN == 1
                    names = obj(idx).name;
                elseif isinf(obj(idx).ensembleN)
                    names = [strcat(obj(idx).name, "_mean"), strcat(obj(idx).name, "_var")];
                else
                    names = strcat( obj(idx).name, "_", string(1:obj(idx).ensembleN) );
                end
                
                tt{idx} = array2timetable( processedValues, 'RowTimes', processedTime, 'VariableNames', names );
            end

            %% finish working
            outputArg = synchronize( tt{:}, 'intersection' );
        end
        
        function outputArg = valid_agg_time( obj, agg_times)
            %valid_agg_time returns true if the aggregation time can be
            %used for the given Forecast. To use on scalar forecast, not for array.
            if isinf(obj.leadTime) || isnan(obj.leadTime)
                outputArg = true( size(agg_times) );
                return;
            end
            
            % get how long is the time to the next available date
            gap_time = obj.time(2:end)-obj.time(1:end-1); 
            gap_time = min(max( days(gap_time) )-1, obj.leadTime);
            
            %it needs to be less then the lead time minus gap_time, i.e when you need
            %to fill some dates, the worst case is when the month is 31 days long for
            %the monthly aggregation.
            if iscalendarduration(agg_times)
                outputArg = obj.leadTime-gap_time>= ( split(agg_times,"days")+31*split(agg_times,"months") );
            else
                outputArg = obj.leadTime-gap_time>= agg_times;
            end
        end
        
        function outputArg = max_leadTime( obj, agg_times )
            %max_leadTime extracts the maximum steap ahead for this couple
            %Forecast - agg_time.
            %   By design it can be maximum 15 anyway.
            %get the maximum lead time, at most 15..
            % To use on scalar forecast, not for array.
            if isinf(obj.leadTime) || isnan(obj.leadTime)
                outputArg = 15*ones(size(agg_times));
                return;
            end
            
            if iscalendarduration( agg_times )
                agg_times = split(agg_times, "days") + 31*split(agg_times, "months");
            end
            
            % get how long is the time to the next available date
            gap_time = obj.time(2:end)-obj.time(1:end-1);
            gap_time = min(max( days(gap_time) )-1, obj.leadTime);
            
            outputArg = max(min( obj.leadTime-gap_time-agg_times, 15 ), 0);
        end
        
        function outputArg = prob2det( obj, method )
            %prob2det transform the probabilistic forecats into a
            %deterministic one.
            %   It's interesting to study the first and the average
            %   ensemble of the probabilistic forecast with more then 1
            %   ensemble. If the forecast has a normal distribution, then
            %   only the mean is possible.
            
            if isinf(obj.ensembleN) || strcmp( method, 'first' )
                %just dump the variance or the following ensembles.
                outputArg = obj;
                outputArg.data = outputArg.data(:,:,1);
            elseif strcmp( method, 'average' )
                outputArg = obj;
                outputArg.data = mean(outputArg.data, 3);
            else 
                error( 'Forecast:wrongInput', ...
                    'Method can be first ensemble ror average of the ensemble.\nFor probabilistic forecats the mean is always extracted.' );
            end
            
            outputArg.ensembleN = 1;
        end
        
        function outputArg = plot( obj, aggTime, step, varargin )
            %plot creates a figure and plot all the ensembles of the
            %probabilistic forecast.
            %   f = plot(probForecast, agg_time, lead_time ) creates a plot
            %   with a time step of agg_time days and lead time of
            %   lead_time day.
            
            if nargin >3 && any( strcmp( varargin, 'Figure' ) )
                idx = find( strcmp( varargin, 'Figure' ), 1, 'first');
                outputArg = varargin{idx+1};
                varargin(idx:idx+1) = [];
                figure(outputArg);
            else
                outputArg = figure;
            end
            hold on;
            
            t = obj.getTimeSeries( aggTime, step, true );
            if isinf(obj.ensembleN)
                % back to values using the inverse cumulative distribution function, I
                % store the variance, but I need to use std dev in this function.
               y = icdf( 'Normal', [0.25, 0.5, 0.75], t{:,1}, t{:,2}.^0.5 );
               plot( t.Time, y, varargin{:} );
            else
                % prob or det
                plot( t.Time, t.Variables, varargin{:} );
            end
            
        end
        
    end
    
    methods ( Access = private )
        
        %{
        function [processedValues, processedTime] = aggregate_unknown( obj, aggTime, step )
            
            n_t = length(obj.time);
            
            % get how long is the time to the next available date
            gap_time = [obj.time(2:end)-obj.time(1:end-1); duration(24,0,0)];
            % get how long is with the required time step
            agg_timeStep = (obj.time+aggTime)-obj.time;
            
            % how many dates do we have to add? if aggregation time is
            % less then gap_time we need to "create some new
            % measurements"
            missing_dates = ceil(gap_time./agg_timeStep) -1;
            missing_dates( missing_dates < 0 ) = 0;
            
            % how many days for this specific agg_time (it can be
            % express in caldays or calmonth)
            agg_timeStep = days(agg_timeStep);
            processedValues = nan( n_t+sum(missing_dates), obj.ensembleN );
            processedTime = NaT( n_t+sum(missing_dates), 1 );
            
            jdx = 1;
            idx = 1;
            while idx <= n_t && jdx <= n_t+sum(missing_dates)
                %how many days from lead time we need to extract plus the
                %only day we really have
                int = (1:(missing_dates(idx)+1)*agg_timeStep(idx)) +(step-1)*agg_timeStep(idx);
                d_int = (0:missing_dates(idx))*agg_timeStep(idx) +(step-1)*agg_timeStep(idx);
                
                extractedValues = obj.data(idx, int, :);
                extractedValues = reshape( extractedValues, agg_timeStep(idx), missing_dates(idx)+1, size(obj.data, 3) );
                extractedValues = mean( extractedValues, 1 );
                
                processedValues( jdx:jdx+missing_dates(idx), :) = squeeze(extractedValues);
                
                processedTime( jdx:jdx+missing_dates(idx), 1 ) = obj.time(idx)+d_int;
                
                jdx = jdx+missing_dates(idx)+1;
                idx = idx+1;
            end
        end
        %}
        function [processedValues, processedTime] = aggregate_unknown( obj, aggTime, leadTime, fill )
            
            n_t = length(obj.time);
            if fill
                % get how long is the time to the next available date
                gap_time = obj.time(2:end)-obj.time(1:end-1);
                % add one for the last measurement
                gap_time(end+1) = datetime(obj.time(end).Year+1, 1, 1)-obj.time(end);
                missing_dates = days( gap_time )-1;
                missing_dates = min( missing_dates, min(obj.leadTime-1, max(missing_dates(1:end-1)) ) );
            else
                missing_dates = zeros(n_t, 1);
            end
            
            q_t = n_t+sum(missing_dates);
            processedValues = nan( q_t, obj.ensembleN );
            processedTime = NaT( q_t, 1 );
            
            % old data index
            idx = 1;
            % new data index
            jdx = 1;
            
            while idx <= n_t && jdx <= q_t
                
                % find out how many days need to be extracted for that day and the
                % subsequent
                pt = days((obj.time(idx)+aggTime) - obj.time(idx));
                    
                %sliding window to eventually fill the dates that are missing
                sw = 0;
                while sw <= missing_dates(idx)
                    
                    % the day I want to create the measurement for is
                    processedTime(jdx) = obj.time(idx) + sw + leadTime;
                    
                    % get the array to extract the values:
                    % aggregation time + shift for missing dates + shift for lead time
                    int_d = (1:pt) + sw + leadTime;
                
                    % extract and place them in processedValues
                    extractedV = obj.data(idx, int_d, :);
                    
                    %mean over lead time, that is future
                    extractedV = mean( extractedV, 2);
                    
                    % remove lead time extra dimension and save them in processed
                    processedValues(jdx,:) = squeeze( extractedV );
                    
                    %move to the day after
                    jdx = jdx +1;
                    sw = sw+1;
                end
                
                idx = idx +1;
            end
            
        end
            
        function outputArg = aggregate_var( obj, aggTime )
            
            vars = obj.data(:, 1, 2);
            agg_timeStep = days((obj.time+aggTime)-obj.time);
            [n_t, n_a] = size( agg_timeStep );
            
            outputArg = nan( n_t, n_a);
            
            for c = 1:n_a
                rs = 1:n_t;
                rs( rs+ agg_timeStep(:, c)'-1 > n_t ) = [];
                for r = rs
                    % is a variance, but we are doing the mean thus I need
                    % to divide by N^2
                    outputArg( r, c) = sum( vars(r:r+agg_timeStep(r,c)-1), 1 )./(agg_timeStep(r,c)^2);
                end
            end
        end
    end
    
end

