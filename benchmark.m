classdef benchmark
    %BENCHMARK is a class to construct the benchamrks starting from the
    %historical and some functions that are common between all the
    %benchmarks.
    
    properties
        value;  % value of the benchmark.
        type;   % type of benchmark.
        maxLT;  % lead time that is needed.
        agg_times;  % array of aggregation times.
        l_agg;  % number of different aggregation times.
        detStats;   %struct with deterministic score.
        probStats;  %strcut with probabilistic score.
    end
    
    methods
        function obj = benchmark(value, type, varargin)
            %BENCHMARK Construct an instance of this class
            %   b = benchmark(value, type) constructs an istance of this
            %   class.
            %   value-type can be:
            %   number-average.
            %   timetable-ciclostationary.
            %   []-consistency.
            
            %% parse input
            valid_types = {'average', 'ciclostationary', 'consistency'};
            
            if ~any([isnumeric(value), istimetable(value), isempty(value)] & strcmpi(type, valid_types) )
                error( 'Benchmark:input', 'Invalid couple value-type.')
            end
            
            if nargin >2
                if strcmp( varargin{1}, 'AggTimes' )
                    if ~iscalendarduration( varargin{2} )
                        error( 'Benchmark:input', 'Invalid input for type AggTimes.')
                    else
                        obj.agg_times = varargin{2};
                    end
                else
                    error( 'Benchmark:input', 'Invalid Name-Value couple.')
                end
            else
                obj.agg_times = [caldays([1; 3; 7; 14; 21; 28; 42]); calmonths(1:7)'];
            end
            
            %% populate
            obj.value = value;
            obj.type = type;
            obj.maxLT = 7;
            %obj.agg_times
            obj.l_agg = length(obj.agg_times);
            obj.detStats = detStats;
            obj.probStats = probStats;
            
            % populate with nan;
            t_ = nan(obj.l_agg, obj.maxLT );
            n = fieldnames(detStats);
            for j = 1:length(n)
                obj.detStats.(n{j}) = t_;
            end
        end
        
        function obj = calculateStats( obj, historical_agg )
            %calculateStats calculates the KGE, KGE', NSE and VE for the
            %benchmark.
            
            name = strcat( "agg_", string( obj.agg_times )' );
            for aggT = 1:obj.l_agg
                % generate the aggregation with the required
                % aggregate historical
                o = historical_agg(:, name(aggT) );
                % if you aggregate the series gets shorter, and it is
                % filled with nans.
                oNan = isnan(o.(1));
                o = o(~oNan, :);
                brier_score.boundaries( brier_score.extract_tercile( o ) );
                % reconstruct with the same aggregation times and dates of
                % the historical.
                b = aggregate( obj, o, obj.agg_times(aggT) );
                
                for lT = 1:obj.maxLT
                    % for each lead time calculate the stats.
                    s = b(:, lT);
                    s.Time = s.Time+lT-1;
                    
                    matchedData = synchronize( s, o, 'intersection' );
                    matchedData.Properties.VariableNames = { 'simulation','observation'};
                    
                    p = KGE( matchedData(:,1), matchedData(:,2), 'Standard' );
                    obj.detStats.kge(aggT, lT) = p.kge;
                    obj.detStats.r(aggT, lT) = p.r ;
                    obj.detStats.alpha(aggT, lT) = p.alpha ;
                    obj.detStats.beta(aggT, lT) = p.beta ;
                    
                    p = KGE( matchedData(:,1), matchedData(:,2), 'Modified' );
                    obj.detStats.kge_mod(aggT, lT) = p.kge;
                    obj.detStats.gamma(aggT, lT) = p.gamma ;
                    
                    p = NSE( matchedData(:,1), matchedData(:,2) );
                    obj.detStats.nse(aggT, lT) = p.nse;
                    
                    obj.detStats.ve(aggT, lT) = VE( matchedData(:,1), matchedData(:,2) );
                    
                    % crps collapse to mae for determintics
                    obj.probStats.crps( aggT, lT ) = MAE( matchedData(:,1), matchedData(:,2) );
                    
                    % brier scores
                    
                    brier_score.type( 'annual' );
                    bs = brier_score.calculate( matchedData(:,1), matchedData(:,2) );
                    
                    obj.probStats.annual_bs.bs(aggT, lT) = bs.bs;
                    obj.probStats.annual_bs.rel(aggT, lT) = bs.rel;
                    obj.probStats.annual_bs.res(aggT, lT) = bs.res;
                    obj.probStats.annual_bs.unc(aggT, lT) = bs.unc;
                    
                    brier_score.type( 'seasonal' );
                    bs = brier_score.calculate( matchedData(:,1), matchedData(:,2) );
                    
                    obj.probStats.seasonal_bs.bs(aggT, lT) = bs.bs;
                    obj.probStats.seasonal_bs.rel(aggT, lT) = bs.rel;
                    obj.probStats.seasonal_bs.res(aggT, lT) = bs.res;
                    obj.probStats.seasonal_bs.unc(aggT, lT) = bs.unc;
                    
                    brier_score.type( 'monthly' );
                    bs = brier_score.calculate( matchedData(:,1), matchedData(:,2) );
                    
                    obj.probStats.monthly_bs.bs(aggT, lT) = bs.bs;
                    obj.probStats.monthly_bs.rel(aggT, lT) = bs.rel;
                    obj.probStats.monthly_bs.res(aggT, lT) = bs.res;
                    obj.probStats.monthly_bs.unc(aggT, lT) = bs.unc;
                    
                    brier_score.type( 'daily' );
                    bs = brier_score.calculate( matchedData(:,1), matchedData(:,2) );
                    
                    obj.probStats.daily_bs.bs(aggT, lT) = bs.bs;
                    obj.probStats.daily_bs.rel(aggT, lT) = bs.rel;
                    obj.probStats.daily_bs.res(aggT, lT) = bs.res;
                    obj.probStats.daily_bs.unc(aggT, lT) = bs.unc;
                    
                end
            end
            
           
        end
    end
    
    methods ( Access = private )
        
        function b = aggregate( obj, historical, agg_time )
            %aggregate generates accordingly to historical and the given
            %aggregation time a time series that is matching the value-type
            %properies of the class.
            
            if strcmp( obj.type, "average" )
                % repeat the same value everywhere
                l = length(historical.Time);
                b = array2timetable(repmat( obj.value, l,   obj.maxLT), 'RowTimes', historical.Time );
                
            elseif strcmp( obj.type, "ciclostationary" )
                %cs = repmat(obj.value.dis24, 2, 1);
                % repeat the ciclostationary timetable, but with one year
                % more
                cs = [timetable( obj.value.Time, obj.value.dis24 );...
                    timetable( obj.value.Time+calyears, obj.value.dis24 )];
                %cs = [obj.value; obj.value];
                cs_agg = zeros(365, 1);
                
                for idx = 1:365
                    % extract the values with the aggregation time
                    tr = timerange( cs.Time(idx), cs.Time(idx)+agg_time );
                    extracted_values = table2array( timetable2table(...
                        cs(tr, 1 ), 'ConvertRowTimes', false ) );
                    % aggregate them
                    cs_agg(idx) = mean( extracted_values );
                end
                
                % get the idx between 1 and 365 from where we need to
                % start.
                st_date = historical.Time(1)-datetime(historical.Time.Year(1), 1, 1);
                st_idx = days(st_date);
                
                % fill b.
                b = zeros( length(historical.Time), 1);
                for idx = 1:length( b )
                    t = mod( st_idx+idx, 365);
                    if t
                        b(idx) = cs_agg(t);
                    else
                        b(idx) = cs_agg(end);
                    end
                end
                
                % the benchmark is the same for all lead times.
                b = repmat( b, 1, obj.maxLT);
                %transform in timetable.
                b = array2timetable( b, 'RowTimes', historical.Time );
                
            elseif strcmp( obj.type, "consistency" )
                
                %for consistency you use the last agg_time elements, so I
                %search where to start.
                st_date = historical.Time(1)+agg_time;
                st_idx = find(historical.Time == st_date, 1, 'first');
                
                % the output will be shorter because you lose some by
                % aggregating.
                b = zeros( length(historical.Time)-st_idx+1, 1);
                % move from st_idx to the end.
                jdx = 1;
                for idx = st_idx:length(historical.Time)
                    t = historical.(1);
                    b(jdx) = mean( t(jdx:idx-1) );
                    jdx = jdx+1;
                end
                
                b = repmat( b, 1, obj.maxLT);
                
                b = array2timetable( b, 'RowTimes', historical.Time(st_idx:end, :) );
                
            else
                error( 'Benchmark:properties', 'Invalid couple value-type.')
            end
            b.Properties.VariableNames = cellstr( strcat( "Lead", num2str((1:obj.maxLT)' )))';
        end
        
    end
end

