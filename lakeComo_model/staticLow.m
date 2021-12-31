classdef staticLow < objFunction
    %STATICLOW Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Access = protected)
        s_low;
    end
    
    
    methods
        function obj = staticLow( param )
            %STATICLOW Construct an instance of this class
            %   Detailed explanation goes here
            if nargin == 0
                obj.s_low =zeros(365,1);
            else
                obj.s_low = param;
            end
        end
        
        function obj = setParam( obj, param)
            
            obj.s_low = obj.validParam(param);
            
        end
        
        function outputArg = evaluate(obj, h, doy)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            
            if nargin == 2 & istimetable(h)
                %i.e. no doy used
                %get doy from h
                doy = h.Time;
                h = h.(1);
            elseif nargin == 3 & isa( h, 'double') & isdatetime( doy )
                %its ok 
            else %should thorw some error
            end
            
            outputArg = sum( double( h < obj.s_low( myDOY(doy) ) ),  1, 'omitnan');
        end
    end
end

