classdef lakeComo < lake
    %LAKECOMO Summary of this class goes here
    %   Detailed explanation goes here
    
    % NO additional properties
    
    methods 
        %same constructor
        
        function a = level2surface(obj, h)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            if nargin < 2
                h = 0;
            end
            
            a = obj.surface;
        end
        
        function s = level2storage(obj, h, p)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            
            if nargin == 2
                p = 0;
            end
            
            h0 = -0.4 + p;
            s = obj.surface*(h-h0);
        end
        
        function h = storage2level(obj, s, p)
            if nargin == 2
                p = 0;
            end
            
            h0 = -0.4+p;
            h = s/obj.surface + h0;
        end
       
        function q = min_release(obj, s, cday, p)
            if nargin == 3 
                p = 0;
            end
           
            cday = cday(:);   % make vertical
            n_t = length(cday);
            s = s(:)'; % make horizontal
            n_s = length( s ) ;
            
            DMV = obj.minEnvFlow( cday, 1);
            h = obj.storage2level( s, p);

            h0 = -0.4 + p;
            q = nan( n_t, n_s );
            
            q(:,  h <= h0) = 0;
            q(:, h>h0 &  h <= 1.10) = DMV*ones(1, size(h(h>h0 &  h <= 1.10), 2) );
            q(:, h > 1.10) = repmat(33.37* (h(:, h > 1.10) +2.5).^2.015, n_t, 1);
            
        end
        
        function q = max_release(obj, s, cday, p )
             if nargin < 4
                p = 0;
             end
             if nargin < 3
                cday = 1;
             end
            
            cday = cday(:);   % make vertical
            n_t = length(cday);
            s = s(:)'; % make horizontal
            n_s = length( s ) ;
            
            h = obj.storage2level( s, p);
            h0 = -0.4 +p;
            
            q = nan( n_t, n_s );
            
            idx = 33.37*((h0+0.1+2.5).^2.015);
            m = idx/0.1;
            it = -m*h0;
            
            q(:,  h <= h0) = 0;
            q(:,  h > h0 &  h<= h0+0.1) = repmat( m*h(:, h > h0 &  h<= h0+0.1) +it, n_t, 1);
            q(:, h >  h0+0.1) =  repmat( 33.37* (h( :, h>h0+0.1)+2.5).^2.015, n_t, 1);
        end
    end
end

