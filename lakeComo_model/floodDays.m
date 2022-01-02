classdef floodDays < objFunction
    %FLOODDAYS Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Access = protected)
        h_flo;
    end
    
    methods
        function obj = floodDays( param )
            %FLOODDAYS Construct an instance of this class
            %   Detailed explanation goes here
            if nargin == 0
                obj. h_flo = 0;
            else
                obj = obj.setParam( param );
            end
        end
        
        function obj = setParam( obj, param)
            
            obj.h_flo = obj.validParam(param);
        end

        function outputArg = evaluate(obj, h)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            
            outputArg = sum(  double( h > obj.h_flo ), 1, 'omitnan' );
        end
        
        function outputArg = norm_eval(obj, h)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            
            outputArg = sum(  double( h > obj.h_flo ), 1, 'omitnan' );
            outputArg = obj.normalize( outputArg );
        end
    end
end

