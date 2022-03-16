classdef lake
    %LAKE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Access = protected)
        initial_condition;      %initial condition %storage or level
        
        surface;
        lsv_rel;
        ev;
        evap_rates;
        tailwater;
        minEnvFlow;
    end
    
    methods
        function obj = lake()
            %LAKE Construct an instance of this class
            %   Detailed explanation goes here
            
        end
        
        %% SET-GET IC
        function obj = setInitCond(obj, ic)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            obj.initial_condition =  ic;
        end
        
        function ic = getInpitCond(obj)
            
            ic = obj.initial_condition;
        end
        
        %% integration
        
        function [s, r] = integration(obj, HH, tt, s0, uu, n_sim, cday, ps, p )
            
            sim_step = 60*60*24/HH; %sec/step
            
            s = [s0; zeros( HH, 1)];
            r = zeros(HH,1);
            
            for idx = 1:HH
                %compute actual release
                r(idx) = obj.actual_release( uu, s(idx), cday, p);
                
                %compute evaporation
                if obj.ev == 1
                    
                    a = obj.level2surface( obj.storage2level(s(idx), p) );
                    
                    e = obj.evap_rates(cday, :)/1000*a/86400;
                elseif obj.ev > 1
                    %todo
                else
                    e = 0;
                end
                
                % sys trans
                s(idx+1) = s(idx) + (n_sim -r(idx) - e)*sim_step;
            end
            
            % take just the final value of the storage and the mean through
            % the day for the release
            s = s(end);
            r = mean( r );
            
        end
        
        function r = actual_release(obj,  uu, s, cday, p)
           
            r = min( obj.max_release( s, cday, p), max( ...
                obj.min_release( s, cday, p), reshape(uu, 1, 1, []) ) );
            
        end
        
%         function outputArg = relToTailWater(obj,  r )
%             
%             if ~isempty( obj.tailwater )
%                 outputArg = interp1( obj.tailwater(0), obj.tailwater(1), r);
%             end
%         end
        
        function obj = setSurface( obj, a )
            obj.surface = a;
        end
        
        function obj = setEvap( obj, pEV) %0 = no evaporation, 1 = from file, 2 = call specific function
            obj.ev = pEV;
        end
        
        %function obj = setEvapRate( obj, evap_rate)
        
        %function obj = setRateCurve( obj, rateCurve)
         
        %function obj = setLSV_rel( obj, lsv_rel)
        
        function obj = setMEF( obj, MEF)
            obj.minEnvFlow = MEF;
        end
        
        function MEF = getMEF( obj, cday )
            
            if nargin > 1
                MEF = obj.minEnvFlow(cday, 1);
            else
                MEF = obj.minEnvFlow;
            end
        end
        
        %function obj = setTailWater
                
    end
end

