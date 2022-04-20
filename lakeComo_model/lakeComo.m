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
                h0 = -0.5;
            else
                h0 = -0.4 + p;
            end
            
            s = obj.surface*(h-h0);
        end
        
        function h = storage2level(obj, s, p)
            if nargin == 2
                h0 = -0.5;
            else
                h0 = -0.4 + p;
            end
            
            h = s/obj.surface + h0;
        end
        
        function [s, r] = integration( obj, HH, tt, s0, uu, n_sim, cday, ps, p, r0 )
            sim_step = 60*60*24/HH; %sec/step
            
            s = [s0; zeros( HH, 1)];
            r = zeros(HH,1);
            
            for idx = 1:HH
                %compute actual release
                r(idx) = obj.actual_release( uu, s(idx), cday, p, n_sim);
                
                %compute evaporation
                if obj.ev == 1
                    
                    a = obj.level2surface( obj.storage2level(s(idx) ) );
                    
                    e = obj.evap_rates(cday, :)/1000*a/86400;
                elseif obj.ev > 1
                    %todo
                else
                    e = 0;
                end
                
                % sys trans
                s(idx+1) = s(idx) + (n_sim -r(idx) - e)*sim_step;
                
            end
            
            % constraint on max dam opening, redefine r and s
            h = obj.storage2level( s0, p );
            if h>1.1
                % dam is already completely open
                % take just the final value of the storage and the mean through
                % the day for the release
                s = s(end);
                r = mean( r );
            else
                % daily increases assuming dr = 30 m3s-1 every 2 hours,
                if h<0.8
                    % but only during daytime 16 hr (no flood risk, h < 0.8)
                    vr = 240;
                else
                    % for the entire day due to flood risk ( h > 0.8 && h< 1.1)
                    vr = 360;
                end
                r = min( mean(r), r0+vr );
                s = s0+ 3600*24*(n_sim-r);
            end
        end
        
        function r = min_release(obj, s, cday, p, q)
            narginchk(3,5);
            
            cday = cday(:);   % make vertical
            n_t = length(cday);
            s = s(:)'; % make horizontal
            n_s = length( s ) ;
            
            if nargin == 3
                p = -0.1;
                q = inf(n_t,1);
            elseif nargin == 4
                q = inf(n_t,1);
            end
            
            % mef in the italian legislation is defined as minimum between value and
            % available inflow
            DMV = min( obj.minEnvFlow( cday, 1), q );
            h = obj.storage2level( s, p);
            
            h0 = -0.4 + p;
            r = nan( n_t, n_s );
            
            % linear part of max release
            idx = 33.37*((h0+0.1+2.5).^2.015);
            m = idx/0.1;
            it = -m*h0;
            q_ = repmat( m*h(:, h > h0 &  h<= 1.10) +it, n_t, 1);
            
            r(:,  h <= h0) = 0;
            
            %min between MEF and LINE
            r(:, h>h0 &  h <= 1.10) = min(q_, DMV*ones(1, size(h(h>h0 &  h <= 1.10), 2) ));
            r(:, h > 1.10) = repmat(33.37* (h(:, h > 1.10) +2.5).^2.015, n_t, 1);
            
        end
        
        function r = max_release(obj, s, cday, p )
            narginchk(3,4);
            
            if nargin == 3
                p = -0.1;
            end
            
            cday = cday(:);   % make vertical
            n_t = length(cday);
            s = s(:)'; % make horizontal
            n_s = length( s ) ;
            
            h = obj.storage2level( s, p);
            h0 = -0.4 +p;
            
            r = nan( n_t, n_s );
            
            idx = 33.37*((h0+0.1+2.5).^2.015);
            m = idx/0.1;
            it = -m*h0;
            
            r(:,  h <= h0) = 0;
            r(:,  h > h0 &  h<= h0+0.1) = repmat( m*h(:, h > h0 &  h<= h0+0.1) +it, n_t, 1);
            r(:, h >  h0+0.1) =  repmat( 33.37* (h( :, h>h0+0.1)+2.5).^2.015, n_t, 1);
        end
        
        function r = actual_release(obj, uu, s, cday, p, q )
            narginchk(3,5);
            
            cday = cday(:);   % make vertical
            n_t = length(cday);
            
            if nargin == 4
                p = -0.1;
                q = inf(n_t,1);
            elseif nargin == 5
                q = inf(n_t,1);
            end
            
            uu = reshape(uu, 1, 1, []);
            
            qm = obj.min_release( s, cday, p, q );
            qM = obj.max_release( s, cday, p );
            
            r = min( qM, max( qm, uu) );
        end
    end
end

