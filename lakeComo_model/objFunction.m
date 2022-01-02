classdef objFunction
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties ( Access = private )
        bias = 0;
        norm = 1;
    end
    
    
    methods
        function obj = setParam( obj, bias, norm )
            obj.bias = bias;
            obj.norm = norm;
        end
        
        function outputArg = getParam( obj )
            warning('off');
            outputArg = struct(obj);
            warning('on');
        end
    end
    
    methods (Access = protected)
        function J = normalize( obj, J )
            J = (J-obj.bias)./obj.norm;
        end
    end
            
    
    methods (Static, Access = protected)
        
        function outputArg = validParam( param )
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            if isa( param, 'double')
                if isscalar( param )
                    outputArg = param;
                    return;
                elseif isvector(param) 
                    outputArg = param(:); % verticalize
                else
                    error( 'objFunction:bad input');
                end
            else
                error( 'objFunction:bad input');
            end
        end
    end
end