classdef probForecast
    %probForecast class that saves the probabilistic forecast coming from
    %the EFAS system.
    %   For more information see EFAS website.
    
    properties
        location;   % Where this forecast has been issued.
        data;       % Cell array of the ensambles.
        leadTime;   % Maximum leadTime available.
        ensembleN;  % Number of the ensambles.
        daysN;      % Number of days extracted
        
        detScores; %struct for the deterministic scores.
    end
    
    methods
        function obj = probForecast( varargin )
            %probForecast construct an istance of this class.
            %   pF = probForecast() constructs an empty istance.
            %   pF = probForecast('Name', 'Value') constructs an istance of
            %   the class.
            %   The available Name-Value pair are:
            %   'data': cell array with timetables with the same size, one
            %   for each ensamble.
            %   'location': struct that contains the information of the
            %   location.
            
            if nargin == 0
                return;
            end
            
            valid_inp = {'data', 'location'};
            
            idx = 1;
            while idx <= length(varargin)
                if strcmp( varargin{idx}, valid_inp{1} )
                    data = varargin{idx+1} ;
                    if ~iscell( data )
                        error( 'PROBF:input', 'The data input is not a cell array.' );
                    end
                    for jdx = 1:length(data)-1
                        if ~isequal( size(data{jdx}), size(data{jdx}) ) | ~isequal(data{jdx}.Time, data{jdx+1}.Time )
                            error( 'PROBF:input', strcat('The data in the cell', ...
                                num2str(jdx+1), 'is not equal to the previous ones.') );
                        end
                    end
                    
                    obj.data = data;
                    obj.ensembleN = length( data );
                    obj.leadTime = size( data{1}, 2);
                    obj.daysN = size( data{1}, 1);
                    
                    idx = idx+2;
                elseif strcmp( varargin{idx}, valid_inp{2} )
                    obj.location = varargin{idx+1};
                    
                    idx = idx+2;
                end
            end
        end
        
        function obj = upload(obj, type, location)
            %UPLOAD uploads from the folder the EFAS forecast of one of the
            %two types: efrf or efsr.
            
            %% input parse
            obj.location = location;
            
            if strcmp( type, 'efrf' )
                dis = 'dis06';
                agg = 4;
            else
                dis = 'dis24';
                agg = 1;
            end
            
            %% upload
            global raw_data_root;
            % get a list of object in the folder and remove all non NetCDF files
            list_element = dir( fullfile( raw_data_root, type , '*.nc') );
            
            % get the number of ensambles.
            ensamble_number = ncread( fullfile( raw_data_root, type, list_element(1).name ), 'number' );
            ensamble_number = length( ensamble_number );
            obj.ensembleN = ensamble_number;
            
            % get the lead times
            step = ncread( fullfile( raw_data_root, type, list_element(1).name ), 'step' );
            obj.leadTime = step(end)/24;
            names = strcat( 'Lead', string((1:obj.leadTime)') )';
            
            %for each element in the folder,
            % extract discharge
            % extract the cell
            % concatenate
            obj.data = cell(1, ensamble_number);
            for idx = 1:length( list_element )
                
                raw_data = ncread( fullfile( raw_data_root, type, list_element(idx).name ), dis );
                raw_data = squeeze( raw_data( location.r, location.c, :, :) );
                
                start_date = ncread( fullfile( raw_data_root, type, list_element(idx).name ), 'time' );
                start_date = datetime(1970, 1, 1) + seconds(start_date);
                
                raw_data = reshape ( raw_data(step>0, :), agg, [], ensamble_number); % in efrf we need to jump the LT= 0, thus start from 2.
                % reshape in 1st_dir:single_day, 2nd_dir:LT,
                % 3rd_dir:ensamble
                raw_data = squeeze( mean( raw_data, 1) );   % mean over the day
                
                for jdx = 1:ensamble_number
                    newF = array2timetable( raw_data(:,jdx)', 'RowTimes', start_date, 'VariableNames', names); % in efsr Lt=0 is not selected
                    obj.data{jdx} = [obj.data{jdx}; newF];
                end
            end
            obj.daysN = size( obj.data{1}, 1 );
        end
        
        function obj = uploadNew(obj, type, location)
            %UPLOAD uploads from the folder the EFAS forecast of one of the
            %two types: efrf or efsr.
            
            %% input parse
            obj.location = location;
            dis = 'dis24';
            
            %% upload
            global raw_data_root;
            % get a list of object in the folder and remove all non NetCDF files
            list_element = dir( fullfile( raw_data_root, type, location.fname , '*.nc') );
            
            % get the number of ensambles.
            raw_data = ncread( fullfile( list_element(1).folder, list_element(1).name ), dis );
            obj.ensembleN = size(raw_data, 2);
            
            % get the lead times
            obj.leadTime = size(raw_data, 1);
            names = strcat( 'Lead', string((1:obj.leadTime)') )';
            
            %for each element in the folder,
            % extract discharge
            % concatenate
            obj.data = cell(1, obj.ensembleN);
            for idx = 1:length( list_element )
                
                raw_data = ncread( fullfile( list_element(idx).folder, list_element(idx).name ), dis );
                
                start_date = ncread( fullfile( list_element(idx).folder, list_element(idx).name ), 'time' );
                start_date = datetime(1970, 1, 1) + seconds(start_date);
                
                for jdx = 1:obj.ensembleN
                    newF = array2timetable( raw_data(:,jdx)', 'RowTimes', start_date, 'VariableNames', names);
                    obj.data{jdx} = [obj.data{jdx}; newF];
                end
            end
            obj.daysN = size( obj.data{1}, 1 );
        end
        
        function outputArg = prob2det(obj, method)
            %prob2det transform the probabilistic forecats into a timetable
            %object.
            %   It's interesting to study the first and the average
            %   ensamble of the probabilistic forecast. This are the only
            %   two available methods.s
            
            %%parse input
            if strcmp( method, 'first' )
                outputArg = obj.data{1};
            elseif strcmp( method, 'average' )
                % average ensamble
                dummy = obj.data;
                
                for idx = 1:obj.ensembleN
                    dummy{idx} = table2array( timetable2table( dummy{idx}, 'ConvertRowTimes',false) );
                end
                
                % reshape into a 3D array.
                dummy = reshape( cell2mat(dummy), obj.daysN, obj.leadTime, obj.ensembleN );
                % mean over the third dimension: the ensambles.
                dummy = mean( dummy, 3);
                
                outputArg = array2timetable( dummy, 'RowTimes', obj.Time );
            else
                error( 'TimeSeries:wrongInput', ...
                    'Error. \nThe method must be either the first or the average.' );
            end
        end
        
        function outputArg = aggregate( obj, agg_time, varargin)
            %aggregate construct a complete time series with the required
            %aggregation time.
            %   t = aggregate( probForecast, agg_time ) constructs a cell
            %   array where the i-th element is a timetable object starting
            %   wfrom the i-th ensamble.
            %   t = aggregate( probForecast, agg_time, 'Name', 'Value', _)
            %   the available Name-value pairs are:
            %   -'Which' : first, average or all to select which
            %   ensamble(s).
            
            
            %   -'OutputStyle' : if the output is shaped as a timetable or
            %   an array
            
            %% parse input
            p = inputParser;
            
            default_type = 'all';
            valid_types = {'first', 'average', default_type};
            check_type = @(x) any(validatestring(x,valid_types));
            
            %             default_outT = 'timetable';
            %             valid_outT = {'array', default_outT};
            %             check_outT = @(x) any(validatestring(x,valid_outT));
            %
            check_value = @(x) obj.valid_agg_time(x);
            
            addParameter(p, 'Which', default_type, check_type);
            %addParameter(p, 'OutputStyle', default_outT, check_outT);
            addRequired(p,'agg_time',check_value);
            
            parse( p, agg_time, varargin{:} );
            agg_time = p.Results.agg_time;
            
            if strcmp(p.Results.Which, valid_types{1} )
                outputArg = obj.aggregate_( obj.prob2det('first'), agg_time);
                
            elseif strcmp(p.Results.Which, valid_types{2} )
                outputArg = obj.aggregate_( obj.prob2det('average'), agg_time);
                
            else
                outputArg = cell( 1, obj.ensembleN);
                for idx = 1:obj.ensembleN
                    outputArg{idx} = obj.aggregate_( obj.data{idx}, agg_time);
                end
                
                outputArg = probForecast( 'data', outputArg, 'location', obj.location );
            end
            
            %             if strcmp(p.Results.OutputStyle, valid_outT{1})
            %                 if istimetable( outputArg )
            %                     % as an array
            %                     outputArg = table2array( timetable2table( ...
            %                         outputArg, 'ConvertRowTimes', false ) );
            %                 elseif isprobForecast( outputArg )
            %                     outputArg = probForecast2array( outputArg );
            %                 end
            %             end
        end
        
        function outputArg = compress( obj, varargin )
            %compress generates from nE ensambles one single timetable
            %object.
            %   t = compress( probForecast ) generates a timetable where
            %   each element is an ensamble. Lead time is 1 day.
            %   Name-Value pair can be:
            %   LeadTime: must be numeric and a valid lead time for the
            %   given probForecast.
            %% parse input varargin
            p = inputParser;
            
            default_lT = 1;
            check_lT = @(x) isnumeric(x) &  (x <= obj.leadTime);
            addParameter(p,'LeadTime', default_lT, check_lT);
            
            parse( p, varargin{:} );
            lead_time = p.Results.LeadTime;
            
            %% extract
            
            dummy = zeros( obj.daysN, obj.ensembleN );
            vn = cell(1, obj.ensembleN );
            for idx = 1:obj.ensembleN
                temp = obj.data{idx};
                dummy(:, idx) = temp.(lead_time);
                vn{idx} = strcat( 'ens_', num2str(idx) );
            end
            
            outputArg = array2timetable( dummy, 'RowTimes', obj.Time );
            % add ens name for consistency
            outputArg.Properties.VariableNames = vn;
            
        end
        
        function outputArg = valid_agg_time( obj, agg_times)
            %valid_agg_time returns true if the aggregation time can be
            %used for the given probabilistic Forecast.
            
            %it needs to be less then the lead time, the worst case is when
            % the month is 31 days long for the monthly aggregation.
            outputArg = iscalendarduration(agg_times) & ...
                (obj.leadTime >= ( split(agg_times,"days")+31*split(agg_times,"months") ) );
        end
        
        function outputArg = max_lead_time( obj, agg_time )
            %max_lead_time extracts the maximum lead time for this couple
            %probForecast agg_time.
            %   By design it can be maximum 7 anyway.
            %get the maximum lead time, at most 7..
            lead_time = split(agg_time, "days") + 31*split(agg_time, "months");
            if lead_time < 31
                outputArg = max( min( floor((obj.leadTime-ceil(31/lead_time)*lead_time)/lead_time +1)...
                    , 7), 1);
            else
                outputArg = min( floor(obj.leadTime/lead_time)...
                    , 7);
            end
        end
        
        function outputArg = plot( obj, varargin )
            %plot creates a figure and plot all the ensambles of the
            %probabilistic forecast.
            %   f = plot( probForecast ) creates a plot with a time step of
            %   one day and lead time of 1 day.
            %   f = plot( probForecast, 'AggTime', agg_time ) creates a
            %   plot with a time step of agg_time days and lead time of 1
            %   day.
            %   f = plot(probForecast, 'AggTime', agg_time, 'LeadTime',
            %   lead_time ) creates a plot with a time step of agg_time
            %   days and lead time of lead_time day.
            
            if nargin >1 & any( strcmp( varargin, 'Figure' ) )
                idx = find( strcmp( varargin, 'Figure' ), 1, 'first');
                outputArg = varargin{idx+1};
                varargin(idx:idx+1) = [];
            else
                outputArg = figure;
            end
            %% parse input
            p = inputParser;
            p.KeepUnmatched = true; % since I need to check AggTime before and then LeadTime I use parse twice.
            
            default_aggTime = caldays(1);
            check_value = @(x) obj.valid_agg_time(x);
            addParameter(p,'AggTime', default_aggTime, check_value);
            
            default_color = 'default';
            check_color = @(x) size(x, 2) == 3; % also size and color but the error is thorow by the function anyway
            addParameter(p,'ColorOrder', default_color, check_color);
            
            parse( p, varargin{:} );
            agg_time = p.Results.AggTime;
            
            default_lT = 1;
            check_lT = @(x) isnumeric(x) &  (x <= obj.max_lead_time( agg_time ));
            addParameter(p,'LeadTime', default_lT, check_lT);
            
            parse( p, varargin{:} );
            lead_time = p.Results.LeadTime;
            colororder( p.Results.ColorOrder );
            
            f = aggregate( obj, agg_time );
            
            %%
            s = f.compress( 'LeadTime', lead_time );
            % extracted all, thus it is a timetable where each column is an
            % ensamble.
            for idx = 1:width(s)
                plot(outputArg, s.Time(lead_time:end), s(1:end-lead_time+1,:).(idx), 'LineWidth', 1 );
                hold on;
            end
            
        end
        
        function outputArg = Time(obj)
            %Time extract the datetime array of the probabilistic forecast.
            outputArg = obj.data{1}.Time;
        end
    end
    
    methods (Access = private)
        
        function outputArg = aggregate_(obj, forecast, agg_time )
            %aggregate generates a timetable starting from a sparse time
            %series with the required aggregation time over all the
            %possible lead times, but at most 7.
            % a = aggregate( probForecast, forecast, agg_time ) generates a
            % timetable starting from forecast object of type timetable
            % with the required aggregation time over all the
            % possible lead times, but at most 7.
            
            if ~istimetable(forecast)
                error( 'probForecast:wrongInput', ...
                    'Error. \nThe input must be a Time Series object.' );
            end
            
            %get the maximum lead time, at most 7..
            lead_time = obj.max_lead_time( agg_time );%to comment until I download
            %all files
            %lead_time = 1;
            names = strcat( "Lead", num2str((1:lead_time)'))';
            
            % create the timetable with the time I want
            outputArg = timetable;
            for idx = 1:length( forecast.Time )-1
                % get how long is the time to the next available date
                gap_time = forecast.Time(idx+1)-forecast.Time(idx) ;
                % get how long is with the required time step
                agg_timeStep = (forecast.Time(idx)+agg_time)-forecast.Time(idx);
                % how many dates do we have to add? if aggregation time is
                % less then gap_time we need to "create some new
                % measurements"
                if (gap_time-1) > agg_timeStep
                    missing_dates = floor( (gap_time-1)/agg_timeStep);
                else
                    missing_dates = 0;
                end
                if agg_timeStep*(missing_dates+1) > size( forecast, 2)
                    missing_dates = 0;
                end
                % how many days for this specific agg_time (it can be
                % express in caldays or calmonth)
                agg_timeStep = days(agg_timeStep);
                %how many days from lead time we need to extract plus the
                %only day we really have
                ne = max(agg_timeStep*(missing_dates+1), agg_timeStep);
                
                
                % we extract the required Lead Time days
                extracted_values = forecast{idx, 1:ne };
                extracV_lt = forecast{idx, (ne+1):(ne+agg_timeStep*(lead_time-1)) };
                
                % reshape so we can aggregate faster
                extracted_values = reshape( extracted_values, agg_timeStep, []);
                extracV_lt = reshape( extracV_lt, agg_timeStep, lead_time-1);
                
                % mean over aggregation time ( dim 1)
                extracted_values = mean( extracted_values, 1)';
                extracV_lt = mean( extracV_lt, 1)';
                
                extractedExtended = zeros( size( extracted_values, 1), lead_time);
                extractedExtended(:,1) = extracted_values;
                for jdx = 2:lead_time
                    extractedExtended(:,jdx) = [extracted_values(jdx:end);extracV_lt(1:(jdx-1))];
                end
                
                outputArg = [outputArg;
                    array2timetable( extractedExtended, 'TimeStep', agg_time, 'StartTime', forecast.Time(idx), 'VariableNames', names )]; %#ok<AGROW>
            end
            % for the last is easier as it is depends just on aggtime
            extracted_values = forecast{end, 1:agg_timeStep*lead_time };
            extracted_values = reshape( extracted_values, agg_timeStep, lead_time);
            extracted_values = mean(extracted_values, 1);
            
            %add the last one
            outputArg = [outputArg;
                array2timetable(extracted_values, 'RowTimes',  forecast.Time(end), 'VariableNames', names )];
            
            % This are forecast issued at time t to have dis24 of time t+1,
            % thus I need to add 1 day.
            outputArg.Time = outputArg.Time + caldays(1);
            
        end
    end
    
    methods (Static)
        function outputArg = type
            %type returns the string 'probForecast'.
            %   It's equal to call class(probForecast).
            %   See also class.
            outputArg = 'probForecast';
        end
    end
end