classdef model_lakecomo_autoSelect
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
        doy_file;           % day of the year (it includes leap years, otherwise doy is computed runtime in the simulation)

        Como_catch_param;
        ComoCatchment
        
        Nex;                % number of exogneous signal to append to the BOP
        ex_signal;          % matrix with exogenous signals, first dimension time, second == Nex
        
        ComoParam;
        LakeComo;
        
        pParam;
        mPolicy;
        
        % objective function data
        warmup;             % number of days of warmup before obj calculation starts
        level_areaFlood;    % level (cm) - flooded area in Como (m2)
        demand;             % total downstream demand (m3/s)
        low;                % value for low levels
        s_low;              % value for static low obj func
        hreg;               % total downstream demand
        rain_weight;        % weight to affect the deficit cost function
        h_flo;              % flooding threshold
        q_hp;               % downstream hydropower demand
        inflow00;           % previous day inflow
        release00;          % previous day release for dam speed constraint, if negative constraint is not active. 

        J;                  % cell array of cost functions 
    end
    
    methods
        function obj = model_lakecomo_autoSelect( filename )
            %MODEL_LAKECOMO Construct an instance of this class
            %   Detailed explanation goes here
            
            %read file settings
            obj = obj.readFileSettings(filename);
            
            %create cathcment and params
            obj.ComoCatchment = load( obj.Como_catch_param.filename, '-ascii' );
            obj.ComoCatchment = obj.ComoCatchment( 1:obj.Como_catch_param.col, 1:obj.Como_catch_param.row );
            
            obj.LakeComo = lakeComo();
            obj.LakeComo = obj.LakeComo.setEvap(0);
            %obj.LakeComo = obj.LakeComo.setMEF( load( 'file', '-ascii') );
            obj.LakeComo = obj.LakeComo.setMEF( 22*ones(obj.H, 1) );
            obj.LakeComo = obj.LakeComo.setSurface( 145900000 );
            obj.LakeComo = obj.LakeComo.setInitCond( obj.ComoParam.initCond );
            
            %policy
            if obj.pParam.tPolicy == 4
                obj.mPolicy = ncRBF( obj.pParam.policyInput, obj.pParam.policyOutput, obj.pParam.policyStr );
            else
                
            end
            
            obj.mPolicy = obj.mPolicy.setMaxInput( obj.pParam.MIn );
            obj.mPolicy = obj.mPolicy.setMaxOutput( obj.pParam.MOut );
            obj.mPolicy = obj.mPolicy.setMinInput( obj.pParam.mIn );
            obj.mPolicy = obj.mPolicy.setMinOutput( obj.pParam.mOut );
            
            %objectives
            % single value
            obj.h_flo = 1.10;
            obj.q_hp = 150;
            
             %load only 365
            obj.demand = load( '~/Documents/Data/utils/aggregated_demand.txt', '-ascii' );
            %obj.low = load( '~/Documents/Data/utils/low_l.txt', '-ascii' );
            obj.s_low = load( '~/Documents/Data/utils/static_low.txt', '-ascii' );
            
            % load H days
            %obj.hreg = load( '~/Documents/Data/utils/regulator.txt', '-ascii' );
            %obj.rain_weight = load( '~/Documents/Data/utils/rain_weight_99_19_LD.txt', '-ascii' );
            
            obj.J = {...
                floodDays( obj.h_flo ); 
                avgDeficitBeta( 'Demand', obj.demand, 'MEF', obj.LakeComo.getMEF ); ...
                staticLow( obj.s_low ) ...
                };
        end
        
        function outputArg = getNobj(obj)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            outputArg = obj.Nobj;
        end
        
        function outputArg = getNvar(obj)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            outputArg = obj.Nvar;
        end

        function [J, h, r] = evaluate(obj, var)
            obj.mPolicy = obj.mPolicy.setParameters(var);
            
            ps = floor(var(end));
            if obj.Nsim < 2
                [J, h, r] = obj.simulate(ps);
            else
                % MC simulation
            end
            
            %obj.mPolicy = obj.mPolicy.clearParameters;
            % automatically deleted as you don't return obj
        end
        
        function J = evaluateFromFile(obj, policyfile)
            var = load( policyfile, '-ascii' );
            obj.mPolicy = obj.mPolicy.setParameters(var);
            
            aT = floor(var(end));
            if obj.Nsim < 2
                J = obj.simulate(1, aT); % 0 in c++ means 1 in MATLAB
            else
                % MC simulation
            end
            
            %obj.mPolicy = obj.mPolicy.clearParameters;
        end
    end
    
    methods( Access = protected )
        
        
        % function to perform the simulation over the scenario ps and aggT aT
        function [J, h, r] = simulate(obj, ps, aT)
            
            s = nan( obj.H+1, 1);
            h = nan( obj.H+1, 1);
            u = nan( obj.H, 1);
            r = nan( obj.H, 1);
            doy = nan( obj.H+1, 1);
            
            h_p = 0;
            
            input = nan(1, obj.Nex+3);
            
            J = nan( obj.getNobj, 1);
            
            % IC 
            qIn = nan;
            qIn_1 = obj.inflow00;
            r_1 = obj.release00;
            h(1) = obj.LakeComo.getInitCond;
            s(1) = obj.LakeComo.level2storage( h(1), h_p );
            
           
            for t = 1:obj.H
                
                %day
                if obj.initDay > 0
                    doy(t) = mod(obj.initDay+t-2, obj.T) +1;
                else
                    doy(t) = obj.doy_file(t);
                end
                
                %inflow
                qIn = obj.ComoCatchment(t, ps);
                
                % decision for policy
                input(1) = sin( 2*pi*doy(t)/obj.T );
                input(2) = cos( 2*pi*doy(t)/obj.T );
                input(3) = h(t);
                for idx = 1:obj.Nex
                    input(1, 3+idx) =obj.ex_signal(t, idx, aT+1); % aT comes from c++ where I start from 0
                end
                
                u(t) = obj.mPolicy.get_NormOutput(input);
                
                if obj.release00 > 0
                    [s(t+1), r(t)] = obj.LakeComo.integration( obj.integStep, t, s(t), u(t), qIn, doy(t), ps, h_p, r_1 );
                else
                    [s(t+1), r(t)] = obj.LakeComo.integration( obj.integStep, t, s(t), u(t), qIn, doy(t), ps, h_p, 10000 );
                end
                h(t+1) = obj.LakeComo.storage2level( s(t+1), h_p );
                
                r_1 = r(t);
                qIn_1 = qIn;
                 
            end
            %save output 
            
            if doy(end-1) == 365
                doy(end) = 1;
            else
                doy(end) = doy(end-1)+1;
            end
            
            
            % remove warmup
            if obj.warmup > 0
                h(1:1+obj.warmup) = [];
                s(1:1+obj.warmup) = [];
                r(1:1+obj.warmup) = [];
            end
            
            %compute objectives 
            %N_years = obj.H/obj.T;
            N_years = 20;
            J(1) = obj.J{1}.evaluate( h(2:end) )/N_years;
            J(2) = obj.J{2}.evaluate( r, 1:obj.H, doy(1:end-1) );
            J(3) = obj.J{3}.evaluate( h(2:end), doy(2:end) )/N_years;
        end
        
        function obj = readFileSettings(obj, filename )
            
            filedir = fileparts( filename );
            
            fid = fopen( filename, 'r' );
            if fid == -1
                error( 'ModelLakeComo:wrongInput', ...
                    'Input settings file not found.' );
            end
            
            obj.Nsim = searchTagSettings(obj, fid, '<NUM_SIM>' );
            fseek( fid, 0, -1 ); % go back to bof
            
            obj.NN = searchTagSettings(obj, fid, '<DIM_ENSEMBLE>' );
            fseek( fid, 0, -1 ); % go back to bof
            
            obj.T = floor(searchTagSettings(obj, fid, '<PERIOD>' ));
            fseek( fid, 0, -1 ); % go back to bof
            
            obj.integStep = searchTagSettings( obj, fid, '<INTEGRATION>' );
            fseek( fid, 0, -1 ); % go back to bof
            
            obj.H = searchTagSettings( obj, fid, '<SIM_HORIZON>' );
            fseek( fid, 0, -1 ); % go back to bof
            
            obj.Nobj = searchTagSettings( obj, fid, '<NUM_OBJ>' );
            fseek( fid, 0, -1 ); % go back to bof
            
            obj.Nvar = searchTagSettings( obj, fid, '<NUM_VAR>' );
            fseek( fid, 0, -1 ); % go back to bof
            
            obj.warmup = searchTagSettings( obj, fid, '<WARMUP>' );
            fseek( fid, 0, -1 ); % go back to bof
            
            obj.initDay = searchTagSettings( obj, fid, '<DOY>' );
            if obj.initDay == 0
                tline = fgetl( fid );
                spline = split( tline );
                % remove initial spaces if present
                while isempty(spline{1})
                    spline(1) = [];
                end
                obj.doy_file = load( fullfile( filedir, spline{1} ) , '-ascii' );
            end
            fseek( fid, 0, -1 ); % go back to bof
            
            obj.Como_catch_param.CM = searchTagSettings( obj, fid, '<CATCHMENT>' );
            tline = fgetl( fid );
            spline = split( tline );
            % remove initial spaces if present
            while isempty(spline{1})
                spline(1) = [];
            end
            obj.Como_catch_param.filename = fullfile( filedir, spline{1} );
            obj.Como_catch_param.row = 1;
            obj.Como_catch_param.col = obj.H;
            fseek( fid, 0, -1 ); % go back to bof
            
            try %since it has been implemented later
                obj.Nex = searchTagSettings( obj, fid, '<ESIGNALS>' );
                obj.ex_signal = nan( obj.H, obj.Nex, obj.NN );
                for idx = 1:obj.Nex
                    tline = fgetl( fid );
                    spline = split( tline );
                    while isempty(spline{1})
                        spline(1) = [];
                    end
                    tempsig = load( fullfile( filedir, spline{1})  , '-ascii');
                    tempsig = reshape( tempsig(1:obj.H*obj.NN), obj.H, 1, obj.NN );
                    obj.ex_signal(:,idx,:) = tempsig;
                    clear tempsig
                end
            catch e
                obj.Nex = 0;
                obj.ex_signal = nan( obj.H, obj.Nex );
            end
            fseek( fid, 0, -1 ); % go back to bof
            
            obj.ComoParam.initCond = searchTagSettings( obj, fid, '<INIT_CONDITION>' );
            fseek( fid, 0, -1 ); % go back to bof
            
            obj.inflow00 = searchTagSettings( obj, fid, '<INIT_INFLOW>' );
            fseek( fid, 0, -1 ); % go back to bof
            
            obj.release00 = searchTagSettings( obj, fid, '<INIT_RELEASE>' );
            fseek( fid, 0, -1 ); % go back to bof
            
            obj.pParam.tPolicy = searchTagSettings( obj, fid, '<POLICY_CLASS>' );
            fseek( fid, 0, -1 ); % go back to bof
            
            obj.pParam.policyInput = searchTagSettings( obj, fid, '<NUM_INPUT>' );
            for idx = 1:obj.pParam.policyInput
                tline = fgetl( fid );
                spline = split( tline );
                while isempty(spline{1})
                    spline(1) = [];
                end
                obj.pParam.mIn(idx) = str2double(spline{1});
                spline(1) = [];
                obj.pParam.MIn(idx) = str2double(spline{1});
                spline(1) = [];
            end
            fseek( fid, 0, -1 ); % go back to bof
            
            obj.pParam.policyOutput = searchTagSettings( obj, fid, '<NUM_OUTPUT>' );
            for idx = 1:obj.pParam.policyOutput
                tline = fgetl( fid );
                spline = split( tline );
                while isempty(spline{1})
                    spline(1) = [];
                end
                obj.pParam.mOut(idx) = str2double(spline{1});
                spline(1) = [];
                obj.pParam.MOut(idx) = str2double(spline{1});
                spline(1) = [];
            end
            fseek( fid, 0, -1 ); % go back to bof
            
            obj.pParam.policyStr = searchTagSettings( obj, fid, '<POLICY_STRUCTURE>' );
            fseek( fid, 0, -1 ); % go back to bof
            
            fclose( fid );
        end
        
        function value = searchTagSettings(~, fid, tag )
            tline = 'a b c';
            spline = split( tline );
            while ~strcmp( spline{1}, tag )
                tline = fgetl( fid );
                spline = split( tline );
            end
            
            value = str2double( spline{2} );
        end
        
    end
end
