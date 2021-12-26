classdef model_lakecomo
    %MODEL_LAKECOMO Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Access = protected)
        %problem setting
        Nsim;               %number of simulation (1=deterministic, >1 MC)
        NN;                 % dimension of the stochastic ensemble
        T;                  % period
        integStep;          % integration timestep = number of subdaily steps
        H;                  % simulation horizon
        Nobj;               % number of objectives
        Nvar;               % number of variables
        initDay;            % first day of simulation
        doy_file;     % day of the year (it includes leap years, otherwise doy is computed runtime in the simulation)

        Como_catch_param;
        ComoCatchment
        
        ComoParam
        LakeComo
        
        pParam
        mPolicy
        
        % objective function data
        warmup;                                 % number of days of warmup before obj calculation starts
        level_areaFlood;    % level (cm) - flooded area in Como (m2)
        demand;                      % total downstream demand (m3/s)
        low;                      % total downstream demand
        s_low;                      % total downstream demand
        hreg;                      % total downstream demand
        rain_weight;                      % total downstream demand
        h_flo;       % flooding threshold
        q_hp;        % downstream hydropower demand
        inflow00;    % previous day inflow

    end
    
    methods
        function obj = model_lakecomo()
            %MODEL_LAKECOMO Construct an instance of this class
            %   Detailed explanation goes here
            
            %read file settings
            %create cathcment and params
            
            obj.LakeComo = lakeComo();
            obj.LakeComo = obj.LakeComo.setEvap(0);
            %MEF ??
            obj.LakeComo = obj.LakeComo.setSurface( 1459000000 );
            obj.LakeComo = obj.LakeComo.setInitCond( Como_param.initCond );
            
            %policy
            
            %objectives
            %allyear
            obj.h_flo = 1.10;
            obj.q_hp = 150;
            
             %load only 365
            obj.demand = load_file;
            obj.low = load_file;
            obj.s_low = load_file;
            
            % load H days
            obj.hreg = load_file;
            obj.rain_weight = load_file;
            
        end
        
        function outputArg = getNobj(obj)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            outputArg = obj.Nobj;
        end
        
%         function outputArg = getNvar(obj)
%             %METHOD1 Summary of this method goes here
%             %   Detailed explanation goes here
%             outputArg = obj.Nvar;
%         end

        function J = evaluate(obj) %, var)
            %obj.mPolicy = obj.mPolicy.setParameter(var);
            
            if obj.Nsim < 2
                J = obj.simulate; %simulate(0);
            else
                % MC simulation
            end
            
            %obj.mPolicy = obj.mPolicy.clearParameter;
        end
    end
    
    methods( Access = protected )
        
        
        % function to perform the simulation over the scenario ps
        function J = simulate(obj) %, ps)
            
            s = nan( obj.H+1, 1);
            h = nan( obj.H+1, 1);
            u = nan( obj.H+1, 1);
            r = nan( obj.H+1, 1);
            doy = nan( obj.H+1, 1);
            
            h_p = 0;
            vr = nan;
            deltaT = 60*60*24;
            
            qIn = nan;
            
            uu = nan;
            input = nan;
            
            J = nan( obj.getNobj, 1);
            
            % IC 
            qIn_1 = obj.inflow00;
            h(1) = obj.LakeComo.getInitCond;
            s(1) = obj.LakeComo.level2storage( h(1), h_p );
            
            qIntot = load_file;
            
           
            for t = 1:H
                
                %day
                % doy(t) = ...
                
                %inflow
                qIn = qIntot(t);
                
                % decision for policy
                %...
                
                u(t) = 0;
                
                % constraint on speed of manouver
                % look on c++ for more info
                if h(t) > 0.8
                    vr = 360;
                else 
                    vr = 240;
                end
                
                [ss, rr] = obj.LakeComo.integration( obj.integStep, t, s(t), u(t), qIn, doy(t), ps, h_p );
                
                if t > 1 & ( r(t)+vr <= rr )
                    r(t+1) = r(t) +vr;
                    s(t+1) = s(t) +(qIn-r(t+1))*deltaT;
                else
                   %without manouver constraint
                   r(t+1) = rr;
                   s(t+1) = ss;
                end
                
            end
            %save output 
            
            % remove warmup
            
            %compute objectives 
            N_years = obj.H/obj.T;
            J(1) = obj.floodDays( h, obj.h_flo )/N_years;
            J(2) = obj.avgDeficitBeta( r, obj.demand, obj.rain_weight, doy );
            J(3) = obj.staticLow( h, obj.s_low, doy )/N_years;
        end
        
        %% Functions to compute the objective functions:
         function outputArg =  floodDays(~, h, h_flo )
             
             outputArg = sum( double( h > h_flo ), 1 );
         end
         
         function outputArg =  avgDeficitBeta(obj, q, w, rain_weight)
             
             %remove MEF
             d = q - obj.LakeComo.getMEF;
             
             %negative values are not allowed, thus set to 0.
             d( d<0 ) = 0;
             
             %deficit, w demand must already be shifted by one day
             d = w-d;
             d( d<0 ) = 0;
             
             %elevate to the requested power
             d = d.^rain_weight;
             
             %average 
             outputArg = mean(d, 1);
         end
         
         function outputArg =  staticLow(~, h, h_ls)
             
             outputArg = sum( double( h < h_ls ), 1 );
         end
    end
end

