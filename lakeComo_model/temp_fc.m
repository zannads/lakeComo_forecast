classdef temp_fc
    %TEMP_FC Temporary forecast class until I can join it with the real
    %hydrological forecast class
    
    properties
        data
        time_length
        at_length
    end
    
    methods
        function obj = temp_fc( filename, time_length, at_length)
            %TEMP_FC Construct an instance of this class
            %   Detailed explanation goes here
            
            if nargin == 0
                return
            end

            rawdata = load( filename , '-ascii' );
            obj.data = reshape( rawdata(1:time_length*at_length), time_length, at_length);
            obj.time_length = time_length;
            obj.at_length = at_length;
        end
        
        function outputArg = get(obj,time, aT)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            outputArg = obj.data(time, aT);
        end
    end
end

