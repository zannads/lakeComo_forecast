classdef time_series
    %TIME_SERIES Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        date = [];
        series = [];
    end
    
    methods
        function obj = time_series(varargin)
            %TIME_SERIES Construct an instance of this class
            %   Detailed explanation goes here
            if nargin == 2
                obj.date = varargin{1};
                obj.series = varargin{2};
            end
        end
    end
end

