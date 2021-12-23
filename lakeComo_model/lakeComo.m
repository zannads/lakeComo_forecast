classdef lakeComo < lake
    %LAKECOMO Summary of this class goes here
    %   Detailed explanation goes here
    
    % NO additional properties
    
    methods 
        %same constructor
        
        function a = level2surface(obj, h)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            a = obj.surface;
        end
        
        function s = level2storage(obj, h, p)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            h0 = -0.4 + p;
            s = obj.surface*(h-h0);
        end
        
        function h = storage2level(obj, s, p)
            
            h0 = -0.4+p;
            h = s/obj.surface + h0;
        end
       
        function q = min_release(obj, s, doy, p)
            DMV = obj.minEnvFlow{ doy, 1};
            h = obj.storage2level( s, p);
            
            h0 = -0.4 + p;
            
            if h <= h0
                q = 0;
            elseif h <= 1.10
                q = DMV;
            else
                q = 33.37* (h+2.5).^2.015;
            end
            
        end
        
        function q = max_release(obj, s, doy, p )
            
            h = obj.storage2level( s, p);
            h0 = -0.4 +p;
            
            idx = 33.37*((h0+0.1+2.5).^2.015);
            m = idx/0.1;
            it = -m*h0;
            
            if h<= h0
                q = 0;
            elseif h<= h0+0.1
                q = m*h+it;
            else
                q = 33.37* (h+2.5).^2.015;
            end
                
        end
        
    end
end

