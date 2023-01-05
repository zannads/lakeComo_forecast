classdef exogenous_signal
    %EXOGENOUS_SIGNAL Class to define exogneous signal on which you can
    %inform the control policy. (temporary)
    %   Detailed explanation goes here
    
    properties (Access=protected)
        data
        time_length
        scenario_number
    end
    
    methods
        function obj = exogenous_signal(filename, time_length, scenario_number)
            %EXOGENOUS_SIGNAL Construct an instance of this class
            %   Detailed explanation goes here

            if nargin == 0
                return;
            end

            rawdata = load( filename , '-ascii' );
            obj.data = reshape( rawdata(1:time_length*scenario_number), time_length, scenario_number);
            obj.time_length = time_length;
            obj.scenario_number = scenario_number;
        end
        
        function outputArg = get(obj,time,scenario)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here

            % should check inputs here, but let MATLAB do the work

            outputArg = obj.data(time, scenario);
        end
    end
end

