classdef forecast_series < hist_series
    %forecast_series A forecast_series class is an extension case of the hist_series
    %class. It is an aggregation of time series with different lead times.
    %   Detailed explanation goes here
    
    properties (Access = protected)
        lead_time = 1;  %LEAD_TIME is the number of days ahead of the forecast. It is summarized as the number of columns of the series attribute.
    end
    
    methods
        function obj = forecast_series()
            %UNTITLED Construct an instance of this class
            %   Detailed explanation goes here
            
        end
        
        function outputArg = get_lt(obj)
            %GET_LT Retrieve lead time of the forecast
            
            outputArg = obj.lead_time;
        end
        
        function obj = set_series(obj, series)
            %get_series Add the time series that is passed as input
            
            % Series must be a vertical array, columns are the lead time
            % steps.
            %Override of hist_series class
           
            obj.series = series; 
        end
        
        function obj = set_lt(obj)
            %GET_LT Retrieve lead time of the forecast
            
            % lead time is automatically obtained by the time series, if
            % there is no time series it's a problem.
            if isempty( obj.series )
                error( 'TimeSeries:emptySeries', ...
                    'Error. \nDefine the time series before calling this function.' );
            end
            
            % lead time is the number of column, thus:
            obj.lead_time = size( obj.series, 2);
        end
        
        function outputArg = extractTS(obj, varargin)
            %get_series Extract the time series with the required
            %boundaries.
            
            default_startdate = obj.date(1);
            default_enddate = obj.date(end);

                p = inputParser;
                % date must be in the right format and also between the
                % time series, otherwise it will go to default
                validDate = @(x) strcmp( class(x), class( datetime ) ) &&...
                    (x >= obj.date(1)) && x<= obj.date(end);
        
                addOptional( p, 'StartDate', default_startdate, validDate);        
                addOptional( p, 'EndDate', default_enddate, validDate);
                
                parse( p, varargin{:} );
                
                startdate = p.Results.StartDate;
                enddate = p.Results.EndDate;
            
            outputArg = obj.series( obj.date >= startdate & obj.date <= enddate ); 
        end
        
    end
end

