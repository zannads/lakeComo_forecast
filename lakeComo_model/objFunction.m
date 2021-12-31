classdef objFunction
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    
    methods
        
        function outputArg = getParam( obj )
            warning('off');
            outputArg = struct(obj);
            warning('on');
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