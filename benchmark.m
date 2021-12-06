classdef benchmark
    %BENCHMARK is a class to construct the benchamrks starting from the
    %historical and some functions that are common between all the
    %benchmarks.
    
    properties
        value;  % value of the benchmark.
        type;   % type of benchmark.
        
        agg_times;  % array of aggregation times.
        l_agg;  % number of different aggregation times.
        detScores;   %struct with deterministic score.
        probScores;  %strcut with probabilistic score.
    end
    
    methods
        function obj = benchmark(value, type, historical, varargin)
            %BENCHMARK Construct an instance of this class
            %   b = benchmark(value, type) constructs an istance of this
            %   class.
            %   value-type can be:
            %   number-average.
            %   timetable-ciclostationary.
            %   ciclostat benchamrk-consistency.
            
            %% parse input
            valid_types = {'average', 'ciclostationary', 'consistency'};
            
            if ~any([isnumeric(value), istimetable(value), isa(value, 'benchmark')] & strcmpi(type, valid_types) )
                error( 'Benchmark:input', 'Invalid couple value-type.')
            end
            
            if nargin > 3
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
            obj.l_agg = length( obj.agg_times );
            
            %% populate
            obj.value = value;
            obj.type = type;
            
            obj.detScores = detScores( [obj.l_agg, 7, 3] );
            obj.probScores = probScores( [obj.l_agg, 7, 3] );
            
            l = length(historical.Time);
            names = strcat( "agg_", string( obj.agg_times) );
            if strcmp( obj.type, "average" )
                % repeat the same value everywhere
                aggSeries = repmat( obj.value, l,   obj.l_agg);
                
            elseif strcmp( obj.type, "ciclostationary" )
               
                % get a time series starting from historical.
                b = cicloseriesGenerator( obj.value, [historical.Time; (historical.Time(end):caldays(1):historical.Time(end)+calyears(1))'] );
                
                aggSeries = zeros( l, obj.l_agg );
                for aggT = 1:obj.l_agg
                    for tdx = 1:l
                        tr = timerange( b.Time(tdx), b.Time(tdx)+obj.agg_times(aggT) );
                        c = b(tr, 1);
                        
                        aggSeries( tdx, aggT ) = mean( c.(1) );
                    end
                end
                
            elseif strcmp( obj.type, "consistency" )
                
                % I start from a ciclostationary, so that where I can't
                % fill I use ciclostationary mean already.
                aggSeries = obj.value.value.Variables;
                for aggT = 1:obj.l_agg
                    %for consistency you use the last agg_time elements, so I
                    %search where to start.
                    st_date = historical.Time(1)+obj.agg_times(aggT);
                    st_idx = find(historical.Time == st_date, 1, 'first');
                    
                    
                    % move from st_idx to the end.
                    jdx = 1;
                    for idx = st_idx:l
                        t = historical.(1);
                        aggSeries(idx, aggT) = mean( t(jdx:idx-1) );
                        jdx = jdx+1;
                    end
                end
            end 
            
            obj.value = array2timetable(aggSeries, ...
                    'RowTimes', historical.Time, 'VariableNames', names );
                
                
        end
    end
end

%{


        function obj = calculateStats( obj, historical_agg, maxLT )
            %calculateStats calculates the KGE, KGE', NSE and VE for the
            %benchmark.
            
            name = strcat( "agg_", reshape( string( obj.agg_times ), [], 1) );
            for aggT = 1:obj.l_agg
                % generate the aggregation with the required
                % aggregate historical
                o = historical_agg(:, name(aggT) );
                % if you aggregate the series gets shorter, and it is
                % filled with nans.
                oNan = isnan(o.(1));
                o = o(~oNan, :);
                brier_score.boundaries( brier_score.extract_tercile( o ) );
                
                s = obj.value(:, name(aggT) );
                
                matchedData = synchronize( s, o, 'intersection' );
                matchedData.Properties.VariableNames = { 'simulation','observation'};
                
                p = KGE( matchedData(:,1), matchedData(:,2), 'Standard' );
                obj.detStats.kge(aggT, 1) = p.kge;
                obj.detStats.r(aggT, 1) = p.r ;
                obj.detStats.alpha(aggT, 1) = p.alpha ;
                obj.detStats.beta(aggT, 1) = p.beta ;
                
                p = KGE( matchedData(:, 1), matchedData(:,2), 'Modified' );
                obj.detStats.kge_mod(aggT, 1) = p.kge;
                obj.detStats.gamma(aggT, 1) = p.gamma ;
                
                p = NSE( matchedData(:,1), matchedData(:,2) );
                obj.detStats.nse(aggT, 1) = p.nse;
                
                obj.detStats.ve(aggT, 1) = VE( matchedData(:,1), matchedData(:,2) );
                
                % crps collapse to mae for determintics
                obj.probStats.crps( aggT, 1 ) = MAE( matchedData(:,1), matchedData(:,2) );
                
                % brier scores
                
                brier_score.type( 'annual' );
                bs = brier_score.calculate( matchedData(:,1), matchedData(:,2) );
                
                obj.probStats.bs(aggT, 1, 1) = bs.bs;
                obj.probStats.rel(aggT, 1, 1) = bs.rel;
                obj.probStats.res(aggT, 1, 1) = bs.res;
                obj.probStats.unc(aggT, 1, 1) = bs.unc;
                
                brier_score.type( 'seasonal' );
                bs = brier_score.calculate( matchedData(:,1), matchedData(:,2) );
                
                obj.probStats.bs(aggT, 1, 2) = bs.bs;
                obj.probStats.rel(aggT, 1, 2) = bs.rel;
                obj.probStats.res(aggT, 1, 2) = bs.res;
                obj.probStats.unc(aggT, 1, 2) = bs.unc;
                
                brier_score.type( 'monthly' );
                bs = brier_score.calculate( matchedData(:,1), matchedData(:,2) );
                
                obj.probStats.bs(aggT, 1, 3) = bs.bs;
                obj.probStats.rel(aggT, 1, 3) = bs.rel;
                obj.probStats.res(aggT, 1, 3) = bs.res;
                obj.probStats.unc(aggT, 1, 3) = bs.unc;
                
                %{
                    brier_score.type( 'daily' );
                    bs = brier_score.calculate( matchedData(:,1), matchedData(:,2) );
                    
                    obj.probStats.daily_bs.bs(aggT, lT) = bs.bs;
                    obj.probStats.daily_bs.rel(aggT, lT) = bs.rel;
                    obj.probStats.daily_bs.res(aggT, lT) = bs.res;
                    obj.probStats.daily_bs.unc(aggT, lT) = bs.unc;
                %}
                
            end
        end
   
     
    end
    
    methods ( Access = private )
        
        function b = aggregate( obj, historical )
            %aggregate generates accordingly to historical and the given
            %aggregation time a time series that is matching the value-type
            %properies of the class.
            
            if strcmp( obj.type, "average" )
                % repeat the same value everywhere
                l = length(historical.Time);
                b = array2timetable(repmat( obj.value, l,   obj.maxLT), 'RowTimes', historical.Time );
                
            elseif strcmp( obj.type, "ciclostationary" )
                %cs = repmat(obj.value.dis24, 2, 1);
                b = cicloseriesGenerator( obj.value, historical );
                % the benchmark is the same for all lead times.
                b = repmat( b.dis24, 1, obj.maxLT);
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
        

%}