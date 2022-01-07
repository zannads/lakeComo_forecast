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
                return;
            end
            
            if ~isdatetime( time )
                error( 'no input' );
            end
            if ~isnumeric(data) || size( data, 1) ~= length(time)
                error( 'bad input' );
            end
            obj.time = time;
            obj.data = data;
            
            defaultLT = size( data, 2);
            defaultEN = size( data, 3);
            defaultBN = false;
            defaultName = "forecast";
            
            validLT = @(x) isscalar(x) && ( isnan(x) || isinf(x) || isnumeric(x) );
            validEN = @(x) isscalar(x) && ( isinf(x) || isnumeric(x) );
            validBN = @(x) isscalar(x) && islogical(x);
            validNA = @(x) isscalar(x) && isstring(x);
            
            p = inputParser;
            addParameter( p, 'LeadTime', defaultLT, validLT );
            addParameter( p, 'EnsembleNumber', defaultEN, validEN );
            addParameter( p, 'Benchmark', defaultBN, validBN );
            addParameter( p, 'Name', defaultName, validNA );
            
            parse( p, varargin{:} );
            
            obj.leadTime = p.Results.LeadTime;
            obj.ensembleN = p.Results.EnsembleNumber;
            obj.benchmark = p.Results.Benchmark;
            obj.name = p.Results.Name;
        end
        
        function outputArg = getTimeSeries( obj, aggTime, step )
            
            %%input check
            
            %%calculations
            if isinf( obj.leadTime )
                % the same value is for all lead times, i.e. I only need to
                % move the dates.
                
                processedValues = obj.data;
                processedTime = obj.time+(step-1)*aggTime;
            elseif isnan( obj.leadTime )
                % the value is perfectly known.. no lead time but
                % aggregation is needed
                % anyway it can still be a probabilistic desc or with
                % ensembles or deterministic with only one
                processedTime = obj.time;
                
                if isinf( obj.ensembleN )
                    processedValues(:,1) = aggregate_historical( obj.time, obj.data(:,1,1), aggTime );
                    processedValues(:,2) = aggregate_var( obj, aggTime );
                else
                    processedValues = squeeze( aggregate_historical( obj.time, obj.data(:,1,:), aggTime ) );
                end
            else
                
                if isinf( obj.ensembleN )
                    %not implemented
                else
                    [processedValues, processedTime] = aggregate_unknown( obj, aggTime, step );
                end
            end
            
            outputArg = array2timetable( processedValues, 'RowTimes', processedTime );
        end
        
        function outputArg = valid_agg_time( obj, agg_times)
            %valid_agg_time returns true if the aggregation time can be
            %used for the given Forecast.
            if isinf(obj.leadTime) || isnan(obj.leadTime)
                outputArg = true( size(agg_times) );
                return;
            end
            
            %it needs to be less then the lead time, the worst case is when
            % the month is 31 days long for the monthly aggregation.
            outputArg = iscalendarduration(agg_times) & ...
                (obj.leadTime >= ( split(agg_times,"days")+31*split(agg_times,"months") ) );
        end
        
        function outputArg = max_step( obj, agg_times )
            %max_step extracts the maximum steap ahead for this couple
            %Forecast - agg_time.
            %   By design it can be maximum 7 anyway.
            %get the maximum lead time, at most 7..
            if isinf(obj.leadTime) || isnan(obj.leadTime)
                outputArg = 7;
                return;
            end
            
            agg_times = split(agg_times, "days") + 31*split(agg_times, "months");
            outputArg = zeros( size(agg_times) );
            
            % get how long is the time to the next available date
            gap_time = [obj.time(2:end)-obj.time(1:end-1); duration(24,0,0)];
            gap_time = max( days(gap_time) );
            
            outputArg( agg_times >= gap_time ) = min( floor( obj.leadTime          ./agg_times( agg_times >= gap_time ) ), 7);
            outputArg( agg_times <  gap_time ) = min( floor((obj.leadTime-gap_time)./agg_times( agg_times <  gap_time ) ), 7);
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
            end
            
            outputArg.ensembleN = 1;
        end
        
    end
    
    methods ( Access = private )
        
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
            while idx <= length( agg_timeStep ) && jdx <= n_t+sum(missing_dates)
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

