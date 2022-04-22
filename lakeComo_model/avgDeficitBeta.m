classdef avgDeficitBeta <objFunction
    %AVGDEFICITBETA Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Access = protected )
        MEF;
        demand;
        rain_weight;
    end
    
    methods
        function obj = avgDeficitBeta( varargin )
            %AVGDEFICITBETA Construct an instance of this class
            %   Detailed explanation goes here
            
            obj.MEF = 0;
            obj.demand = zeros(365,1);
            obj.rain_weight = [];
            
            param_flag = {'Demand', 'MEF', 'RainWeight' };
            param_fc = {'setDemand', 'setMEF', 'setRW'};
            
            for idx = 1:length( param_flag )
                wh = find( strcmpi( param_flag{idx}, varargin), 1, 'first' );
                if ~isempty(wh)
                    obj = obj.(param_fc{idx})( varargin{wh+1} );
                    varargin( [wh, wh+1] ) = [];
                end
            end
            
        end
        
        function obj = setMEF( obj, param)
            
            obj.MEF = obj.validParam(param);
            
        end
        
        function obj = setDemand( obj, param)
            
            obj.demand = obj.validParam(param);
        end
        
        function obj = setRW( obj, param)
            
            obj.rain_weight = obj.validParam(param);
        end
        
        function outputArg = evaluate( obj, q, cday, doy)
            
            %remove MEF
            d = q - obj.MEF( cday );
            
            %negative values are not allowed, thus set to 0.
            d( d<0 ) = 0;
            
            %deficit
            d = obj.demand( doy ) -d;
            d( d<0 ) = 0;
            
            %elevate to the requested power
            if ~isempty( obj.rain_weight )
                d = d.^(2-obj.rain_weight(cday) );
            else
                d(doy>=91 & doy<=283) = d(doy>=91 & doy<=283).^2; % squared during summer, abs value rest of the year
            end
            
            %average
            outputArg = mean(d, 1, 'omitnan');
        end
        
        function outputArg = norm_eval( obj, q, cday, doy)
            
            %remove MEF
            d = q - obj.MEF( cday );
            
            %negative values are not allowed, thus set to 0.
            d( d<0 ) = 0;
            
            %deficit
            d = obj.demand( doy ) -d;
            d( d<0 ) = 0;
            
            %elevate to the requested power
            d = d.^(2-obj.rain_weight(cday) );
            
            %average
            outputArg = mean(d, 1, 'omitnan');
            outputArg = obj.normalize( outputArg );
        end
        
    end
end

