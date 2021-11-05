classdef hist_series
    %HIST_SERIES Class to handle the time series for the thesis project
    %   Detailed explanation goes here
    
    properties
        name = string();
        description = string();
    end
    
    properties (Access = protected)
        date = [];
        series = [];
        coordinate = struct('lon', [], 'lat', []);
    end
    
    methods
        function obj = hist_series()
            %HIST_SERIES Construct an instance of this class
            %   Detailed explanation goes here
        end
        
        function outputArg = get_series(obj)
            %get_series Retrieve the whole property without any
            %modification at all
            
            outputArg = obj.series;
        end
        
        function outputArg = get_date(obj)
            %get_series Acquire the datetime of the timeseries
            
            outputArg = obj.date;
        end
        
        function outputArg = get_coordinate(obj)
            %get_series Get the coordinates of where this time series takes
            %place
            %   Coordinate is a struct with latitude and longitude.
            outputArg = obj.coordinate;
        end
        
        function obj = set_series(obj, series)
            %get_series Add the time series that is passed as input
            
            % Series must be 1-D vertical array
            [r, c] = size( series );
            if c > r
                series = series';
            end
            
            % if larger then one column just lose the following
            obj.series = series(:, 1);
        end
        
        function obj = set_date(obj, start_date)
            %get_series Generate the timestamp array for the time series
            %   Time series naturally don't come with a reference on the day for each
            %   element in the series. So, I create a parallel array so
            %   that I can reference value also using dates.
            
            if isempty( obj.series )
                error( 'TimeSeries:emptySeries', ...
                    'Error. \nDefine the time series before calling this function.' );
            end
            
            % generate a date for each element in the time series, minus one
            % to get the last. use the number of rows as it time series are
            % vertical and extension of this class will use columns for
            % different lead times.
            end_date = start_date + caldays( size( obj.series, 1) -1);
            %%TODO check that is not in the future...
            
            obj.date = start_date:caldays(1):end_date;
            % verticalize
            obj.date = obj.date';
        end
        
        function obj = set_coordinate(obj, longitude, latitude)
            %get_series Set the coordinates of where this time series takes
            %place
            
            obj.coordinate = struct( 'lat', latitude, 'lon', longitude );
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
            
            % array : [date, observations] 
            outputArg = time_series( obj.date( obj.date >= startdate & obj.date <= enddate ),...
                obj.series( obj.date >= startdate & obj.date <= enddate ) );
        end
        
    end
end

