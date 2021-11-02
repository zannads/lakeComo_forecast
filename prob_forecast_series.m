classdef prob_forecast_series < forecast_series
    %prob_forecast_series Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Access = protected)
        ensamble = 1;
    end
    
    methods
        function obj = prob_forecast_series()
            %prob_forecast_series Construct an instance of this class
            %   Detailed explanation goes here
        end
        
        function outputArg = method1(obj,inputArg)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            outputArg = obj.Property1 + inputArg;
        end
    end
end

